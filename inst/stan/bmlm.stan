// Stan code for multilevel mediation model

data {
    int<lower=1> N;             // Number of observations
    int<lower=1> J;             // Number of participants
    int<lower=1,upper=J> id[N]; // Participant IDs
    vector[N] X;                // Manipulated variable
    vector[N] M;                // Mediator
    vector[N] Y;                // Outcome
    real prior_scale;           // Prior scale for regression params
    real intrcpt_scale;         // Prior scale for intercepts
}
transformed data{
    real y_mean;                // Mean of Y
    int K;                      // Number of predictors
    y_mean = mean(Y);
    K = 5;
}
parameters{
    // Regression Y on X and M
    real dy;                    // Intercept
    real cp;                    // X to Y effect
    real b;                     // M to Y effect
    real<lower=0> sigma_y;      // Residual
    // Regression M on X
    real dm;                    // Intercept
    real a;                     // X to M effect
    real<lower=0> sigma_m;      // Residual

    // Correlation matrix and SDs of participant-level varying effects
    cholesky_factor_corr[K] L_Omega;
    vector<lower=0>[K] tau;

    // Standardized varying effects
    matrix[K, J] z_U;
}
transformed parameters {
    // Participant-level varying effects obtained from vectorized and
    // standardized z_U matrix
    matrix[J, K] U;

    // Sample varying effects from Cholesky factorized covariance matrix
    // diag_pre_multiply(tau, L_Omega) = Cholesky covariance matrix
    U = (diag_pre_multiply(tau, L_Omega) * z_U)';

}
model {
    // Means of linear models
    vector[N] mu_y;
    vector[N] mu_m;
    // Cholesky factor of covariance matrix
    matrix[K, K] L_Sigma;
    // Regression parameter priors
    dy ~ normal(0, intrcpt_scale);
    dm ~ normal(0, intrcpt_scale);
    a ~ normal(0, prior_scale);
    b ~ normal(0, prior_scale);
    cp ~ normal(0, prior_scale);
    // RE SDs and correlation matrix
    tau[1] ~ cauchy(0, 1);      // u_cp
    tau[2] ~ cauchy(0, 1);      // u_b
    tau[3] ~ cauchy(0, 1);      // u_a
    tau[4] ~ cauchy(0, 1);      // u_intrcpt_y
    tau[5] ~ cauchy(0, 1);      // u_intrcpt_m
    L_Omega ~ lkj_corr_cholesky(2);
    // Allow vectorized sampling of varying effects via stdzd z_U
    to_vector(z_U) ~ normal(0, 1);

    // Regressions (No intercepts: assume within-person deviated variables)
    for (n in 1:N){
        mu_y[n] = (cp + U[id[n], 1]) * X[n] +
                  (b + U[id[n], 2]) * M[n] +
                  (dy + U[id[n], 4]);
        mu_m[n] = (a + U[id[n], 3]) * X[n] +
                  (dm + U[id[n], 5]);
    }

    // Data model
    Y ~ normal(mu_y, sigma_y);
    M ~ normal(mu_m, sigma_m);
}
generated quantities{
    // Transform Cholesky factorized correlation matrix to corrmat and covmat
    matrix[K, K] Omega;         // Correlation matrix
    matrix[K, K] Sigma;         // Covariance matrix

    // Average mediation parameters
    real covab;                 // a-b covariance
    real corrab;                // a-b correlation
    real ab;                    // Indirect effect
    real c;                     // Total effect
    real pme;                   // % mediated effect

    // Person-specific mediation parameters
    vector[J] u_ab;
    vector[J] u_cp;
    vector[J] u_c;
    vector[J] u_pme;

    Omega = L_Omega * L_Omega';
    Sigma = quad_form_diag(Omega, tau);

    covab = Sigma[3,2];
    corrab = Omega[3,2];
    ab = a*b + covab;
    c = cp + a*b + covab;
    pme = ab / c;

    for (j in 1:J) {
        u_ab[j] = (a + U[j, 3]) * (b + U[j, 2]);
        u_cp[j] = cp + U[j, 1];
        u_c[j] = u_cp[j] + u_ab[j];
        u_pme[j] = u_ab[j] / u_c[j];
    }
}