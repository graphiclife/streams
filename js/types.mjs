//
//  Codecs
//

export class Codec {
  static OPUS = new Codec('opus');
  static G722 = new Codec('g722');
  static PCMU = new Codec('pcmu');
  static PCMA = new Codec('pcma');
  static TELEPHONE_EVENT = new Codec('telephone-event');
  static H264 = new Codec('h264');
  static VP8 = new Codec('vp8');
  static VP9 = new Codec('vp9');
  static AV1 = new Codec('av1');

  static ALL = [
    Codec.OPUS,
    Codec.G722,
    Codec.PCMU,
    Codec.PCMA,
    Codec.TELEPHONE_EVENT,
    Codec.H264,
    Codec.VP8,
    Codec.VP9,
    Codec.AV1,
  ];

  constructor(codec) {
    if (codec instanceof Codec) {
      this.codec = codec.codec;
    } else if (typeof codec === 'string' || codec instanceof String) {
      this.codec = codec.toLowerCase();
    }
  }

  get mimeType() {
    if (this.equals(Codec.OPUS)) {
      return 'audio/opus';
    } else if (this.equals(Codec.G722)) {
      return 'audio/G722';
    } else if (this.equals(Codec.PCMU)) {
      return 'audio/PCMU';
    } else if (this.equals(Codec.PCMA)) {
      return 'audio/PCMA';
    } else if (this.equals(Codec.TELEPHONE_EVENT)) {
      return 'audio/telephone-event';
    } else if (this.equals(Codec.H264)) {
      return 'video/h264';
    } else if (this.equals(Codec.VP8)) {
      return 'video/VP8';
    } else if (this.equals(Codec.VP9)) {
      return 'video/VP9';
    } else if (this.equals(Codec.AV1)) {
      return 'video/AV1';
    } else {
      return 'application/octet-stream';
    }
  }

  equals(codec) {
    if (codec instanceof Codec) {
      return this.codec === codec.codec;
    }

    if (typeof codec === 'string' || codec instanceof String) {
      return this.codec === codec.toLowerCase();
    }

    return false;
  }

  valueOf() {
    return this.codec;
  }

  toString() {
    return this.codec;
  }

  toJSON() {
    return this.toString();
  }
}

export class CapabilityName {
  static events = new CapabilityName('events');
  static useInbandFec = new CapabilityName('useinbandfec');

  static ALL = [
    CapabilityName.events,
    CapabilityName.useInbandFec,
  ];

  constructor(capabilityName) {
    if (capabilityName instanceof CapabilityName) {
      this.capabilityName = capabilityName.capabilityName;
    } else if (typeof capabilityName === 'string' || capabilityName instanceof String) {
      this.capabilityName = capabilityName.toLowerCase();
    }
  }

  equals(capabilityName) {
    if (capabilityName instanceof CapabilityName) {
      return this.capabilityName === capabilityName.capabilityName;
    }

    if (typeof capabilityName === 'string' || capabilityName instanceof String) {
      return this.capabilityName === capabilityName.toLowerCase();
    }

    return false;
  }

  valueOf() {
    return this.capabilityName;
  }

  toString() {
    return this.capabilityName;
  }

  toJSON() {
    return this.toString();
  }
}

export class Capability {
  #name;
  #value;

  constructor(capability) {
    if (capability instanceof Capability) {
      this.#name = capability.name;
      this.#value = capability.value;
    } else if (typeof capability === 'object' && capability !== null) {
      this.#name = capability.name;
      this.#value = capability.value;
    } else {
      throw new Error('invalid capability');
    }
  }

  get name() {
    return this.#name;
  }

  get value() {
    return this.#value;
  }

  toJSON() {
    return {
      name: this.name,
      value: this.value,
    };
  }
}

export class PayloadInfo {
  #type;
  #codec;
  #clockRate;
  #channels;
  #capabilities;

  constructor({ type, codec, clockRate, channels, capabilities }) {
    this.#type = type;
    this.#codec = new Codec(codec);
    this.#clockRate = clockRate;
    this.#channels = channels || 0;
    this.#capabilities = (capabilities || []).map(capability => new Capability(capability));
  }

  get type() {
    return this.#type;
  }

  get codec() {
    return this.#codec;
  }

  get clockRate() {
    return this.#clockRate;
  }

  get channels() {
    return this.#channels;
  }

  get capabilities() {
    return this.#capabilities;
  }

  modify({ type, codec, clockRate, channels, capabilities }) {
    return new Payload({ 
      type: type || this.type,
      codec: codec || this.codec,
      clockRate: clockRate || this.clockRate,
      channels: channels || this.channels,
      capabilities: capabilities || this.capabilities,
    });
  }

  toJSON() {
    return {
      type: this.type,
      codec: this.codec,
      clockRate: this.clockRate,
      channels: this.channels,
      capabilities: this.capabilities,
    };
  }
}

export class PortTuple {
  #rtp;
  #rtcp;

  constructor(tuple) {
    if (tuple instanceof PortTuple) {
      this.#rtp = tuple.rtp;
      this.#rtcp = tuple.rtcp;
    } else if (typeof tuple === 'object' && tuple !== null) {
      this.#rtp = tuple.rtp;
      this.#rtcp = tuple.rtcp;
    } else {
      throw new Error('invalid port tuple');
    }
  }

  get rtp() {
    return this.#rtp;
  }

  get rtcp() {
    return this.#rtcp;
  }

  toJSON() {
    return {
      rtp: this.rtp,
      rtcp: this.rtcp,
    };
  }
}

export class Transport {
  #host;
  #port;

  constructor({ host, port }) {
    this.#host = host;
    this.#port = new PortTuple(port);
  }

  get host() {
    return this.#host;
  }

  get port() {
    return this.#port;
  }

  toJSON() {
    return {
      host: this.host,
      port: this.port,
    };
  }
}
