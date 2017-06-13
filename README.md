# neuralnet2cpp
<strong>Compute your R 'neuralnet' neural network using cpp code.</strong>

You can train you neural network with R:
<pre>
&gt; data &lt;- data.frame( i1 = c(1, 2, 4), i2 = c(5, 5, 6), o = c(1, 1, 0) )
&gt; net &lt;- neuralnet( o~i1+i2, hidden = c( 5, 2 ) )
</pre>

Then test your net:
<pre>
&gt; test &lt;- data.frame( i1 = 5, i2 = 1 )
&gt; res &lt;- compute( net, test )
&gt; res$net.result
               [,1]
[1,] -0.08056605515
</pre>

And convert that network into cpp:
<pre>
> compute.gen.cpp( net, "~/myprojects/subfolder/compute.cpp" )
</pre>

Test your network using compute.cpp:
<pre>
int main(int argc, char *argv[])
{
    double covariates[2] = { 5, 1 };
    double results[1] = { 0 };
    neuralnet::compute( &amp;covariates[0], &amp;results[0] );
    printf( "%f\n", results[0] ); // -0.080566
    return 0;
}
</pre>
