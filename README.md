# MQTT.jl

[![Build Status](https://travis-ci.org/rweilbacher/MQTT.jl.svg?branch=master)](https://travis-ci.org/rweilbacher/MQTT.jl)
[![Coverage Status](https://coveralls.io/repos/github/kivaari/MQTT.jl/badge.svg?branch=master)](https://coveralls.io/github/kivaari/MQTT.jl?branch=master)

MQTT Client Library

This code builds a library which enables applications to connect to an MQTT broker to publish messages, and to subscribe to topics and receive published messages.

This library supports: fully asynchronous operation, file persistence

Contents
--------
 TODO

Installation
------------
```julia
Pkg.clone("https://github.com/rweilbacher/MQTT.jl.git")
```
Testing
-------
```julia
Pkg.test("MQTT")
```
Usage
-----
Use the library by "using" it.

Samples are available in the `examples` directory.
```julia
using MQTT
```

## Getting started
TODO

## Client
The client struct is used to store state for an MQTT connection. All callbacks, apart from on_message, can't be set through the constructor and have to be set manually after instantiating the client struct.

Fields in the Client that are relevant for the library user:
* ping_timeout: Time, in seconds, the Client waits for the PINGRESP after sending a PINGREQ before he disconnects ; default = 60 seconds
* on_message: This function gets called upon receiving a publish message from the broker.
* on_disconnect:
* on_connect: 
* on_subscribe:
* on_unsubscribe: 

##### Constructors
All constructors take the on_message callback as an argument.

```julia
Client(on_msg::Function)
```

Specify a custom ping_timeout
```julia
Client(on_msg::Function, ping_timeout::UInt64)
```

## Publish
After a MQTT client is connected to a broker, it can publish messages.  
```julia
publish(client::Client, topic::String, payload...; dup::Bool=false, qos::UInt8=0x00, retain::Bool=false
```
Once the broker receives the message from the publish function above, it will then send the message to any clients subscribing to matching topics. Publish consists of these arguments:

* client: connect to the MQTT client
* topic: the message should be pubished on
* payload: the actual message to be sent
* dup: The duplicate (DUP) flag, which is set in the case a PUBLISH is redelivered, is only for internal purposes and won’t be processed by broker or client in the case of QoS 1. The receiver will send a PUBACK regardless of the DUP flag.
* qos: the quality of service level to use
* retain: A retained message is an MQTT message with the retained flag set to true. If set to True, the message will be set as the "last known good"/retained message for the topic.
  
The function `publish_async` is used so it can be consumed by `publish`.
Distinguished by qos, the `message` is sorted and subsequently `write_packet` prepares the packet to be published.

## Subscribe / Unsubscribe
Subscribe to a topic and receive messages.

```julia
subscribe(client, topics...)
```
* client: connect to the MQTT client
* topic: a string for the client to subscribe to


Unsubscribe the client from one or more topics.

```julia
unsubscribe(client, topics...)
```
* topic: a single string, or list of strings that are the subscription topics to unsubscribe from.

Just like Publish, Subscribe/ Unsubscribe also uses `subscribe_async`and `unsubscribe_async` for the same reason.
