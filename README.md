utils-libs
==========

Utility modules containing relatively generic, reusable functions sorted by the predominant datatype they manipulate.


Quick release notes
-------
Not all libs have comprehensive function documentation or tests, but you can always help with that... that's why its now all public.

Note that some functions are very old and selectively picked from even older projects as these where cleaned-up.  This means you may have word name collision with more recent functions in the last R2 releases.  You may also find some redundancy or differences in their implementation wrt equivalent functions in R2.  Just use slim's run-time import renaming feature to alleviate any issues.

A lot of the code is compatible with Rebol 3, but I have not yet done ANY work to make sure so don't expressly recommend using this code "blind" in R3.  If you want to help to port/very this code, I'd happy to get contributions, and will create the appropriate .reb file equivalent which will load in the slim version which already works in Rebol 3 (slim.reb) .
