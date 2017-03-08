/*==========================================================
 * updatePrior.c - example in MATLAB External Interfaces
 *
 *
 * The calling syntax is:
 *
 *		outMatrix = arrayProduct(multiplier, inMatrix)
 *
 * This is a MEX-file for MATLAB.
 * Copyright 2007-2012 The MathWorks, Inc.
 *
 *========================================================*/

#include "mex.h"
#include <math.h>
#include "gsl\gsl_rng.h"
#include "gsl\gsl_randist.h"

/*Reads particlevalue at position i,j (0-based indexing)*/
double readParticle(double *particles,int p,int j,int num_p){
	return particles[(j*num_p)+p];
}

void copyParticle(double * destParticles,double * sourceParticles,int dest_p, int source_p,size_t num_p, size_t dim_p) {
	for (int dim = 0; dim < dim_p; dim++) {
		destParticles[num_p*dim + dest_p] = sourceParticles[num_p*dim + source_p];
	}
}

/*Reads matrix at position i,j (0-based indexing)*/
double readMatrix(double *matrix,size_t i,size_t j,size_t num_i){
	return matrix[(j*num_i)+i];
}


/*Reads particlevalue at position i,j (0-based indexing)*/
double readObsX(double *obs_x,size_t obs, int option,int attr,int num_obs,int num_a){
	return obs_x[( option*num_obs*num_a + attr * num_obs + obs )];
}

/*Compute logit probability */
double LogitProba(int p,int choice,int obs,int num_p, int num_obs, int num_option, double* particles,double* obs_x) {
	double u_top = 0.0;
	double proba = 0.0;
	int num_a = 2;
	for(int a=0;a<num_a;a++){
		u_top += readParticle(particles,p,a,num_p)*pow(readObsX(obs_x,obs,choice,a,num_obs,num_a),readParticle(particles,p,2,num_p));
	}
	double eu_top = exp(pow(u_top, 1/readParticle(particles, p, 2, num_p)));
	
	double u_option = 0.0;
	double eu_bottom = 0.0;
	for(int i=0;i<num_option;i++){
		u_option = 0.0;
		for(int a=0;a<num_a;a++){
			u_option += readParticle(particles,p,a,num_p)*pow(readObsX(obs_x,obs,i,a,num_obs,num_a), readParticle(particles, p, 2, num_p));
		}
		eu_bottom += exp(pow(u_option,1/ readParticle(particles, p, 2, num_p)));
	}
	proba = (eu_top / eu_bottom) > 0.000000000001 ? (eu_top / eu_bottom) : 0.000000000001 ;
	return proba;
};

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    double *outMatrix;              /* output matrix */
	double *eta;

	//init RNG
	const gsl_rng_type * T;
	gsl_rng * rng;
	gsl_rng_env_setup();
	T = gsl_rng_default;
	rng = gsl_rng_alloc(T);
	gsl_rng_set(rng, 1234567);


    /* check for proper number of arguments */
    if(nrhs!=3) {
        mexErrMsgIdAndTxt("MyToolbox:updatePrior:nrhs","Three input required.");
    }
    if(nlhs!=1) {
        mexErrMsgIdAndTxt("MyToolbox:updatePrior:nlhs","One output required.");
    }
	
	/* get the number of particles */
	size_t num_p = mxGetM(prhs[2]); //lines
	size_t dim_p = mxGetN(prhs[2]); //columns
	
	/* get the number of observations */
	size_t num_obs = mxGetM(prhs[1]);
	
	double * obsChoiceReal = mxGetPr(prhs[0]);
	int * obsChoice = malloc(num_obs * sizeof(int));
	for (int d = 0; d < num_obs; d++) {
		obsChoice[d] = round(obsChoiceReal[d]);
	}

	double * obs_x = mxGetPr(prhs[1]);
	double * particles = mxGetPr(prhs[2]);
	
	double * logweight = malloc(num_p * sizeof(double));
	
	/*---Update Particles---*/
	//Correction
	for(int p=0;p<num_p;p++){
		logweight[p] = log( LogitProba(p,(int) obsChoice[(num_obs-1)],(num_obs-1),num_p,num_obs,/*num options*/ 2,particles,obs_x) );
	}
	
	//Selection
	double totWeight = 0.0;
	double * levelSelect = malloc(num_p * sizeof(double));
	double weight = 0.0;
	double drawUnif = 0.0;
	double * thetaRedraw = malloc(num_p * dim_p * sizeof(double));

	for (int p = 0; p < num_p; p++) {
		//give nan a weight of 0
		weight = (logweight[p] != logweight[p]) ? 0 : exp(logweight[p]);
		totWeight += weight;
		levelSelect[p] = totWeight;
	}
	//redraw
	for (int p = 0; p < num_p; p++) {
		drawUnif = gsl_rng_uniform(rng) * totWeight;
		copyParticle(thetaRedraw, particles, p, 0, num_p, dim_p);
		for (int j = num_p - 1; j >= 0; j--) {
			if (drawUnif > levelSelect[j]) {
				copyParticle(thetaRedraw, particles, p, j+1, num_p, dim_p);
				break;
			}
		}
	}

	//copy theta
	for (int p = 0; p < num_p; p++) {
		copyParticle(particles, thetaRedraw, p, p, num_p, dim_p);
	}

	//compute sd
	double * theta_mean = calloc(dim_p,sizeof(double));
	double * theta_sd = calloc(dim_p, sizeof(double));
	/*for (int dim = 0; dim < dim_p; dim++) {
		for (int p = 0; p < num_p; p++) {
			theta_mean[dim] += particles[dim * num_p + p];
			theta_sd[dim] += particles[dim * num_p + p] * particles[dim * num_p + p];
		}
		theta_sd[dim] = pow((theta_mean[dim] + theta_sd[dim]) / num_p, 0.5);
		theta_sd[dim] = (theta_sd[dim] < 0.05) ? 0.05 : theta_sd[dim];
	}*/

	//Mutation
	for (int m = 0; m < 10; m++) {
		for (int p = 0; p < num_p; p++) {
			for (int dim = 0; dim < dim_p; dim++) {
				thetaRedraw[num_p * dim + p] = particles[num_p * dim + p] +  gsl_ran_gaussian(rng, 0.02);
			}
			double log_mh_ratio_top = 0.0; // log(objModel.PriorPDF(thetaRedraw[i]));
			double log_mh_ratio_bot = 0.0; // log(objModel.PriorPDF(theta[i]));
			for (int d = 0; d < num_obs; d++) {
				log_mh_ratio_top += log(LogitProba(p, (int)obsChoice[d], d, num_p, num_obs, 2, thetaRedraw, obs_x));
				log_mh_ratio_bot += log(LogitProba(p, (int)obsChoice[d], d, num_p, num_obs, 2, particles, obs_x));
			}
			double log_mh_ratio = log_mh_ratio_top - log_mh_ratio_bot;
			if (log(gsl_rng_uniform(rng)) < log_mh_ratio ) {
				copyParticle(particles, thetaRedraw, p, p, num_p, dim_p);
			}
		}
	}
	

	
	//---------------------------//
    /* create the output matrix */
    plhs[0] = mxCreateDoubleMatrix((mwSize)num_p,(mwSize) dim_p,mxREAL);

    /* get a pointer to the real data in the output matrix */
    outMatrix = mxGetPr(plhs[0]);
	
	for(int d=0;d<dim_p;d++){
		for(int p=0;p<num_p;p++){
			outMatrix[(d*num_p+p)] = particles[(d*num_p+p)];
		}
	}
	
	free(theta_sd);
	free(logweight);
	free(thetaRedraw);
	gsl_rng_free(rng);
}