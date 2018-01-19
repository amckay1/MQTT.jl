struct Publish <: Packet
    header::UInt8
    id::UInt16
    message::Message
end

Publish(message::Message) = Publish(convert(UInt8, PUBLISH) | ((message.dup & 0x1) << 3) | (convert(UInt8, message.qos) << 1) | message.retain, 0x0000, message)
Publish(packet::Publish, id::UInt16) = Publish(packet.header, id, packet.message)

function read(s::IO, flags::UInt8, ::Type{Publish})
    dup = (flags & 0x08) >> 3
    qos = (flags & 0x06) >> 1
    retain = (flags & 0x01)
    topic = mqtt_read(s, String)
    id = 0x0000
    if qos != 0x00
        id = mqtt_read(s, UInt16)
    end
    payload = take!(s)
    return Publish(PUBLISH, id, Message(dup, qos, retain, topic, payload))
end

function write(s::IO, packet::Publish)
    mqtt_write(s, packet.message.topic)
    if packet.message.qos != AT_MOST_ONCE
        mqtt_write(s, packet.id)
    end
    write(s, packet.message.payload)
end

function needs_id(packet::Publish)
    return packet.message.qos != AT_MOST_ONCE
end

function has_id(packet::Publish)
    return packet.message.qos != AT_MOST_ONCE
end

Base.show(io::IO, x::Publish) = print(io, "PUBLISH[", ((x.message.qos == AT_MOST_ONCE) ? "" : "id: $(x.id) "), "message: ", x.message, "]")

struct Puback <: Ack
    header::UInt8
    id::UInt16

    Puback(id) = new(PUBACK, id)
end
Base.show(io::IO, x::Puback) = print(io, "PUBACK[id: ", x.id, "]")

struct Pubrec <: Ack
    header::UInt8
    id::UInt16

    Pubrec(id) = new(PUBREC, id)
end
has_id(packet::Pubrec) = false
Base.show(io::IO, x::Pubrec) = print(io, "PUBREC[id: ", x.id, "]")

struct Pubrel <: Ack
    header::UInt8
    id::UInt16

    Pubrel(id) = new(convert(UInt8, PUBREL) | 0x02, id)
end
has_id(packet::Pubrel) = false
Base.show(io::IO, x::Pubrel) = print(io, "PUBREL[id: ", x.id, "]")

struct Pubcomp <: Ack
    header::UInt8
    id::UInt16

    Pubcomp(id) = new(PUBCOMP, id)
end
Base.show(io::IO, x::Pubcomp) = print(io, "PUBCOMP[id: ", x.id, "]")
