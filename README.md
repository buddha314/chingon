# Chingon v 0.1.5

The (Ch) (I)mplementation of (N)umerical (G)raph (O)peratio(n)s is a [GraphBLAS](http://graphblas.org/)-like library written in [Chapel](https://chapel-lang.org/).

Chingon is (will be) designed to be similar to a Property Graph, in that the vertices will have attributes, but is not a database.  It is more akin to [igraph](http://igraph.org/), [Pregel](https://blog.acolyer.org/2015/05/26/pregel-a-system-for-large-scale-graph-processing/) or [Giraph](http://giraph.apache.org/) but, alas, considerably humbler in scope.

Please do consider [contributing](CONTRIBUTING.md) to the project.  We can assist by being very nice and providing a delicious cup of coffee when in Pasadena, CA.

At the moment, we are only aware of one other [GraphBLAS](https://github.com/cmu-sei/gbtl) implementation. Some impressive work has been done at the Lawrence Berkeley National Lab by [Azad and Buluc](https://chapel-lang.org/CHIUW/2017/azad-slides.pdf) that has not (yet) been open-sourced.  However, using Linear Algebra to tackle graph routines is a clear step forward in the intersection of Network analytics and High Performance Computing.

## Related Projects

* Notably, that of [Azad and Buluc](https://chapel-lang.org/CHIUW/2017/azad-slides.pdf)
* Chingon uses [NumSuch](https://github.com/buddha314/numsuch) for the underlying statistical methods.  It's inception is a response to [this ticket](https://github.com/buddha314/numsuch/issues/35) and this [earlier ticket](https://github.com/chapel-lang/chapel/issues/6840)
* Chingon is attempting to be compatible with [Mason](https://chapel-lang.org/docs/master/tools/mason/mason.html).
* Chingon uses the heck out of the [CDO Project](https://github.com/marcoscleison/cdo).
