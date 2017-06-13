compute.gen.cpp <-
function (x, path, rep = 1, float.type = "double", namespace = TRUE) 
{
    fd = file( path, open = "wt" );

    nn <- x
    linear.output <- nn$linear.output
    weights <- nn$weights[[rep]]
    nrow.weights <- sapply( weights, nrow )
    ncol.weights <- sapply( weights, ncol )
    length.weights <- length( weights )
    num.covariates <- nrow.weights[1] - 1

    act.fct.type <- attributes( nn$act.fct )$type
    if ( act.fct.type == "logistic" || act.fct.type == "tanh" )
    {
        cat( "#include <math.h>\n", file = fd )
        cat( "\n", file = fd )
    }

    if ( namespace )
    {
        cat( "namespace neuralnet\n", file = fd )
        cat( "{\n", file = fd )
        cat( "\n", file = fd )
    }

    act.fct.cpp <- act.fct.type
    if ( act.fct.type == "logistic" )
    {
        act.fct.cpp <- "act_fct"
        cat( "static ", float.type, " act_fct(", float.type, " x)\n", sep = "", file = fd )
        cat( "{\n", file = fd )
        cat( "    return 1 / ( 1 + exp(-x) );\n", file = fd )
        cat( "}\n", file = fd )
        cat( "\n", file = fd )
    }

    cat( "void compute(const ", float.type, " *covariates, ", float.type, " *results)\n", sep = "", file = fd )
    cat( "{\n", file = fd )

    if ( num.covariates > 1 )
    {
        for ( i in 0:(num.covariates - 2) )
        {
            cat( "    const ", float.type, " n0_", i, " = *(covariates++);\n", sep = "", file = fd )
        }
    }
    cat( "    const ", float.type, " n0_", (num.covariates - 1), " = *(covariates);\n", sep = "", file = fd )
    cat( "\n", file = fd )

    for ( l in 1:length.weights )
    {
        layer.weights <- weights[[l]]
        layer.intercepts <- layer.weights[1,]

        act.fct.use = act.fct.cpp
        if ( l == length.weights && linear.output )
        {
            act.fct.use <- ""
        }

        for ( n in 1:(ncol.weights[l]) )
        {
            intercept <- layer.intercepts[n]
            multsum <- paste( "(", layer.weights[2, n], ") * n", (l - 1), "_0", sep = "" )
            if ( nrow.weights[l] > 2 )
            {
                for ( i in 3:(nrow.weights[l]) )
                {
                    multsum <- paste( multsum, " + (", layer.weights[i, n], ") * n", (l - 1), "_", (i - 2), sep = "" )
                }
            }
            if ( l == length.weights )
            {
                if ( n == ncol.weights[l] )
                {
                    cat( "    *results = ", act.fct.use, "( ", intercept, " + ", multsum, " );", sep = "", file = fd )
                }
                else
                {
                    cat( "    *(results++) = ", act.fct.use, "( ", intercept, " + ", multsum, " );\n", sep = "", file = fd )
                }
            }
            else
            {
                cat( "    const ", float.type, " n", l, "_", (n - 1), " = ", act.fct.use, "( ", intercept, " + ", multsum, " );\n", sep = "", file = fd )
            }
        }
        cat( "\n", file = fd )
    }

    cat( "}\n", file = fd )
    cat( "\n", file = fd )

    if ( namespace )
    {
        cat( "} // namespace neuralnet\n", file = fd )
    }

    close( fd )
}
