#=
Initial implementation
Author: Pia Ofalsa
        758000
=#

"""

Main class for use communicating with an MQTT broker

MQTT is a lightweight pub/sub messaging
protocol that is easy to implement and
suitable for low powered devices.
"""

#connect to the host on port / sets up TCP/IP connections
import Base.connect
include("messagetypes.jl")




struct Client
  """
  #keepalive: Maximum period in seconds between
  # communications with the broker.
  """
  keep_alive::UInt16
  """
  If implemented, called when a message has been
   received on a topic
  that the client subscribes to.
  """
  on_msg::Function
  socket::TCPSocket
end

function write_msg(client, cmd, payload...)
  buffer = PipeBuffer()
  for i in payload
    if typeof(i) === String
      write(buffer, hton(convert(UInt16, length(i))))
    end
    write(buffer, i)
  end
  """
  take!(b::IOBuffer)
  Obtain the contents of an IOBuffer as an array, without copying. Afterwards, the IOBuffer is reset to its initial state.
  take!(c::Channel)
  Removes and returns a value from a Channel. Blocks until data is available.
  For unbuffered channels, blocks until a put! is performed by a different task.
  take!(rr::RemoteChannel, args...)
  Fetch value(s) from a RemoteChannel rr, removing the value(s) in the processs.
  take! has 8 methods:
  """
  data = take!(buffer)
  len = hton(convert(UInt8, length(data)))
  write(client.socket, cmd, len, data)
end

function read_msg(client)
  cmd = read(client.socket, UInt8)
  len = read(client.socket, UInt8)

  if cmd === CONNACK
    rc = read(client.socket, UInt16)
    println(rc)
  end
end

function connect(host::AbstractString, port::Int, on_msg::Function)
  client = Client(0, on_msg, connect(host, port))
  protocol = "MQTT"
  protocol_version = 0x04
  flags = 0x02 # clean session

  """client_id is the unique client id string
  used when connecting to the broker.
        """
  client_id = "Pia"

  write_msg(client, CONNECT, protocol, protocol_version, flags, client.keep_alive, client_id)
  println("connected to ", host, ":", port)

  read_msg(client)

  client
end

function disconnect(client)
  write_msg(client, DISCONNECT)
  close(client.socket)
  println("disconnected")
end

function subscribe(client, topics...)
"""
TODO:

Subscribe the client to one or more topics.

    This function may be called in three different ways:

    Simple string and integer
    -------------------------
    e.g. subscribe("my/topic", 2)

    topic: A string specifying the subscription topic to subscribe to.
    qos: The desired quality of service level for the subscription.
         Defaults to 0.

    String and integer tuple
    ------------------------
    e.g. subscribe(("my/topic", 1))

    topic: A tuple of (topic, qos). Both topic and qos must be present in
           the tuple.
    qos: Not used.

    List of string and integer tuples
    ------------------------
    e.g. subscribe([("my/topic", 0), ("another/topic", 2)])

    This allows multiple topic subscriptions in a single SUBSCRIPTION
    command, which is more efficient than using multiple calls to
    subscribe().

    topic: A list of tuple of format (topic, qos). Both topic and qos must
           be present in all of the tuples.
    qos: Not used.

    The function returns a tuple (result, mid), where result is
    MQTT_ERR_SUCCESS to indicate success or (MQTT_ERR_NO_CONN, None) if the
    client is not currently connected.  mid is the message ID for the
    subscribe request. The mid value can be used to track the subscribe
    request by checking against the mid argument in the on_subscribe()
    callback if it is defined.

    Raises a ValueError if qos is not 0, 1 or 2, or if topic is None or has
    zero string length, or if topic is not a string, tuple or list.
"""
end

function publish(client, topic, bytes)

  """If implemented, called when a message that was to be sent using the
      publish() call has completed transmission to the broker.

      For messages with QoS levels 1 and 2, this means that the appropriate
      handshakes have completed. For QoS 0, this simply means that the message
      has left the client.
      This callback is important because even if the publish() call returns
      success, it does not always mean that the message has been sent."""
end
