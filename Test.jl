#commit: add connect sample

# module mqtt

include("Client.jl")

function on_msg(topic, msg)
end

client = connect("test.mosquitto.org", 1883, on_msg)
disconnect(client)

println("I am ready")
# end
