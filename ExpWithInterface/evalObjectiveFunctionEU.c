/*==========================================================
 * evalObjectiveFunction.c - example in MATLAB External Interfaces
 *
 *
 * This is a MEX-file for MATLAB.
 * Copyright 2007-2012 The MathWorks, Inc.
 *
 *========================================================*/

#include "mex.h"
#include <math.h>

/*Reads particlevalue at position i,j (0-based indexing)*/
double readParticle(double *particles,size_t p,size_t j,size_t num_p){
	return particles[(j*num_p)+p];
}

/*Reads particlevalue at position i,j (0-based indexing)*/
double readMatrix(double *matrix,size_t i,size_t j,size_t num_i){
	return matrix[(j*num_i)+i];
}

/*Compute expected utility with CRRA model */
double ExpCrraU(int p,int choice,int num_p, int num_x ,int num_a,double* particles,double* options){
    double eu = 0.0;
    double scale = readParticle(particles,p,0,num_p);
    double riskcoef = readParticle(particles,p,1,num_p);
    double proba = readMatrix(options,choice,0,num_x);
    double reward = readMatrix(options,choice,1,num_x);
    if( riskcoef<1.0001 && riskcoef >0.9999 ){
        eu = scale * (proba/100) * log(reward);
    }else{
        eu = scale * (proba/100) * (pow(reward,1-riskcoef)-1) / (1-riskcoef);
    }
    return eu;
}

/*Compute logit probability */
double LogitProba(int p,int choice,int num_p, int num_x ,int num_a,double* particles,double* options) {
	double * u;
    u = (double *) malloc(num_x * sizeof(double));
    double max_u = -10000.0;
    int hasinf = 0;
    //compute utilities
    for(int i=0;i<num_x;i++){
        u[i] = ExpCrraU(p,i,num_p,num_x ,num_a,particles,options);
        if(u[i]>max_u){
            max_u = u[i];
        }
    }
    //remove max_u from every utility to avoid inf.
    double logit_denom = 0.0;
    for(int i=0;i<num_x;i++){
        u[i] = u[i]-max_u;
        logit_denom = logit_denom + exp(u[i]);
    }
	double proba = (exp(u[choice]) / logit_denom) > 0.000000000001 ? (exp(u[choice]) / logit_denom) : 0.000000000001;
    free(u);
	return proba;
}

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    double *particles;               /* P x 2 input matrix */
    double *outMatrix;              /* output matrix */
	double *eta;                    // Experiement design: eta = (x1,x2)

    /* check for proper number of arguments */
    if(nrhs!=2) {
        mexErrMsgIdAndTxt("MyToolbox:evalObjectiveFunction:nrhs","One input required.");
    }
    if(nlhs!=1) {
        mexErrMsgIdAndTxt("MyToolbox:evalObjectiveFunction:nlhs","One output required.");
    }
	
	/* get the number of particles */
	size_t num_p = mxGetM(prhs[0]); //lines
	size_t dim_p = mxGetN(prhs[0]); //columns
	
	/* get the number of choices */
	size_t num_x = mxGetM(prhs[1]);
	/* get the number of attributes */
	size_t num_a = mxGetN(prhs[1]);
	
	particles = mxGetPr(prhs[0]);
	eta = mxGetPr(prhs[1]);
	
    /* create the output matrix */
    plhs[0] = mxCreateDoubleMatrix((mwSize)1,(mwSize) 1,mxREAL);

    /* get a pointer to the real data in the output matrix */
    outMatrix = mxGetPr(plhs[0]);
	
	/* Compute optimal design */
	//allocate memory for p(y=i|theta_p,eta), size: num_particles * num_choice_options
	double * py_ip = malloc(num_x * num_p * sizeof(double));
	double * py_i = malloc(num_x * sizeof(double));
	
	for(int i=0;i<num_x;i++){
		py_i[i]=0.0;
		for(int p=0;p<num_p;p++){
			py_ip[(p+num_p*i)]= LogitProba(p,i,num_p,num_x,num_a,particles,eta); //compute probability
			py_ip[(p+num_p*i)]= py_ip[(p+num_p*i)] > 0.0000000000001 ? py_ip[(p+num_p*i)] : 0.0000000000001;
			py_i[i] += py_ip[(p+num_p*i)];
		}
		py_i[i]=py_i[i]/num_p;
	}
	
	//compute U(eta) <- the exp utility of the researcher from experiment eta
	double u_eta = 0.0; 
	//double u_hist[1024];
	for(int i=0;i<num_x;i++){
		for(int p=0;p<num_p;p++){
			u_eta += log( py_ip[(p+num_p*i)] / py_i[i] ) * py_ip[(p+num_p*i)];
		}
	}
	
	outMatrix[0] = u_eta;
	
	//Debug
	//plhs[0] = mxCreateDoubleMatrix((mwSize)(1+ num_x + 1024),(mwSize) 1,mxREAL);
	//outMatrix = mxGetPr(plhs[0]);
	//outMatrix[0] = u_eta;
	//outMatrix[1] = py_i[0];
	//outMatrix[2] = py_i[1];
	//for(int i=0;i<1024;i++){
	//	outMatrix[3+i] = py_ip[i];
	//}
	
	free(py_ip);
	free(py_i);
}
