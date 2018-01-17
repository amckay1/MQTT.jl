#=
Initial implementation
Author: Pia Ofalsa and Jonathan Noble
        758000 and 757996 respectively
=#

"""Main class for use communicating with an MQTT broker

MQTT is a lightweight pub/sub messaging
protocol that is easy to implement and
suitable for low powered devices."""

#connect to the host on port / sets up TCP/IP connections
import Base.connect
include("messagetypes.jl")

# commands
const CONNECT = 0x10
const CONNACK = 0x20
const PUBLISH = 0x30
const PUBACK = 0x40
const PUBREC = 0x50
const PUBREL = 0x60
const PUBCOMP = 0x70
const SUBSCRIBE = 0x80
const SUBACK = 0x90
const UNSUBSCRIBE = 0xA0
const UNSUBACK = 0xB0
const PINGREQ = 0xC0
const PINGRESP = 0xD0
const DISCONNECT = 0xE0


mutable struct Client
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
  last_id::UInt16
  in_flight::Dict{UInt16, Future}

end

function packet_id(client)
  if client.last_id == typemax(UInt16)
    client.last_id = 0
  end
  client.last_id += 1
  return client.last_id
end

function write_msg(client, cmd, payload...)
  buffer = PipeBuffer()
  for i in payload
    if typeof(i) === String
      write(buffer, hton(convert(UInt16, length(i))))
    end
    write(buffer, i)
  end

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


function connect(client::Client, host::AbstractString, port::Integer=1883;
  keep_alive::UInt16=0x0000, client_id = "Pia")
  protocol_name = "MQTT"
  protocol_lvl = 0x04
  flags = 0x02 # clean session

  write_msg(client, CONNECT,
  protocol_name, protocol_lvl,
  flags, client.keep_alive,
  client_id)

  println("connected to ", host, ":", port)
end


function disconnect(client)
  write_msg(client, DISCONNECT)
  close(client.socket)
  println("disconnected")
end

function subscribe(client, topics...)
  future = Future()
  id = packet_id(client)
  client.in_flight[id] = future

  write_msg(client, SUBSCRIBE | 0x02, id, topics...)

  topic = collect(topics)
    for (i, v) in enumerate(future)
      if i % 2 == 0
        result[i * 2] = v
      end
    end

  println("subscribed to ", topic)
end

function unsubscribe_async(client, topics...)
  future = Future()
  id = packet_id(client)
  client.in_flight[id] = future

  write_msg(client, UNSUBSCRIBE | 0x02, id, topics...)

  println("unsubscribed from ", topics)
end


function publish(client, topics, payload...)
  buffer = PipeBuffer()
  for i in payload
    write(buffer, i)
  end
  encoded_payload = take!(buffer)

  future = Future()

  if qos == 0x00
    put!(future, nothing)
  elseif qos == 0x01 || qos == 0x02
    future = Future()
    id = packet_id(client)
    client.in_flight[id] = future
  else
    throw(println("invalid qos"))
  end

  write_msg(client, PUBLISH | 0x30, encoded_payload)
  return future
end
