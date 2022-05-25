# PowerShell can infer generic <T> for method calls for your, when it has a parameter of the same type <T>
# Example: Enumerable.Distinct<TSource>(IEnumerable<TSource>)
# TSource can be inferred from the argument
[System.Linq.Enumerable]::Distinct([int[]]@(1,2,3,1,2))

# Let's say you want to call a generic method without ability to infer types.
# Example: Enumerable.OfType<TResult>()
# Idially you may expect syntax like this
# [System.Linq.Enumerable].OfType[int](@(,@(1,2,'a'))
# where you tell PowerShell type explicitly.
# Unfortunately, that doesn't work.

# But there is a work-around.
# You just need to construct MethodInfo instance yourself using reflection

$method = [System.Linq.Enumerable].GetMethod('OfType')
$m = $method.MakeGenericMethod([int])
$m.Invoke($null, @(,@(1,2,'a'))) # @(,@(1,2,'a')), because Invoke() expects array of arguments, so we need to wrap sequence twice.