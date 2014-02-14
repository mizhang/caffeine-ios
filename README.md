This is the objective-c implementation of caffeine.

# Implmentation decisions

## Top-down vs bottom-up

It's worth documenting that while it's natural in Python to spawn classes just-in-time and hang them off a RPCWorker, in ObjC it's not natural.  It used to be; but now with ARC the compiler wants to know what method you're calling and what its return type is and what time you'll be home.

So what becomes natural in ObjC is to simply generate stubs for classes.  But the problem becomes what should be done to map `-[Foo bar]` to a URL.  You could make everything `[Foo bar: (Connection*) baz]` or something but this is terribly complicated.  So what is done instead is we simply encode the URL into each class.  This could cause problems in the case that two URLs define the same class but presumably that could be solved later.

## Programming style

A futures-based RPC system was considered, and may yet still be implemented, but the author has [some objections](http://sealedabstract.com/code/broken-promises/) and an opportunity has not arisen to adequately resolve them.

## Errors

As a practical matter, all Python code can throw exceptions, and meanwhile Objective-C uses an explicit pattern based on NSError.

Two different patterns are planned for this problem.  The traditional one:

    NSError *err = nil;
    BOOL ok = [Baz myMethodWithError:&error];
    if (!ok) {
        //do something with err
    }

The advantage of the traditional API is explicit control over thread semantics.

And a blocks-based API:

    [Baz myMethodWithResult:^(id result) { ... } orError:^(NSError *err) { ... }];

The advantage of the blocks-based API is easy asynchronicity and defining error handlers at an app-wide level.