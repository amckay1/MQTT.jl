""" module declares a Module, which is a separate global variable workspace.
    Within a module, you can control which names from other modules are visible (via importing),
    and specify which of your names are intended to be public (via exporting). For example:
    Modules allow you to create top-level definitions without worrying about name conflicts
    when your code is used together with somebody else’s.
     Void has no methods.
"""
module MQTT


import Base: connect, ReentrantLock, lock, unlock
using Base.Threads, Base.Dates

"""
Evaluate the contents of the input source file in the current context.
Returns the result of the last evaluated expression of the input file.
During including, a task-local include path is set to the
directory containing the file. Nested calls to include will search
relative to that path. All paths refer to files on node 1 when running in parallel,
and files will be fetched from node 1. This function is typically used to load source interactively,
or to combine files in packages that are broken into multiple source files.
include(path::AbstractString) at base\sysimg.jl:8
"""

include("utils.jl")
include("client.jl")

#export is used within modules and packages to tell Julia which functions should be made available to the user
export
    Client,
    connect_async,
    connect,
    subscribe_async,
    subscribe,
    unsubscribe_async,
    unsubscribe,
    publish_async,
    publish,
    disconnect,
    get

end
