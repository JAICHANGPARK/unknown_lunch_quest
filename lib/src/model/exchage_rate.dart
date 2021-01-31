class ExchangeRate {
  Rates rates;

  ExchangeRate({this.rates});

  ExchangeRate.fromJson(Map<String, dynamic> json) {
    rates = json['rates'] != null ? new Rates.fromJson(json['rates']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.rates != null) {
      data['rates'] = this.rates.toJson();
    }
    return data;
  }
}

class Rates {
  Btc btc;
  Eth eth;
  Eth ltc;
  Eth bch;
  Eth bnb;
  Eth eos;
  Eth xrp;
  Eth xlm;
  Eth link;
  Eth dot;
  Eth yfi;
  Eth usd;
  Eth aed;
  Eth ars;
  Eth aud;
  Eth bdt;
  Eth bhd;
  Eth bmd;
  Eth brl;
  Eth cad;
  Eth chf;
  Eth clp;
  Eth cny;
  Eth czk;
  Eth dkk;
  Eth eur;
  Eth gbp;
  Eth hkd;
  Eth huf;
  Eth idr;
  Eth ils;
  Eth inr;
  Eth jpy;
  Eth krw;
  Eth kwd;
  Eth lkr;
  Eth mmk;
  Eth mxn;
  Eth myr;
  Eth ngn;
  Eth nok;
  Eth nzd;
  Eth php;
  Eth pkr;
  Eth pln;
  Eth rub;
  Eth sar;
  Eth sek;
  Eth sgd;
  Eth thb;
  Eth twd;
  Eth uah;
  Eth vef;
  Eth vnd;
  Eth zar;
  Eth xdr;
  Eth xag;
  Eth xau;
  Btc bits;
  Btc sats;

  Rates(
      {this.btc,
        this.eth,
        this.ltc,
        this.bch,
        this.bnb,
        this.eos,
        this.xrp,
        this.xlm,
        this.link,
        this.dot,
        this.yfi,
        this.usd,
        this.aed,
        this.ars,
        this.aud,
        this.bdt,
        this.bhd,
        this.bmd,
        this.brl,
        this.cad,
        this.chf,
        this.clp,
        this.cny,
        this.czk,
        this.dkk,
        this.eur,
        this.gbp,
        this.hkd,
        this.huf,
        this.idr,
        this.ils,
        this.inr,
        this.jpy,
        this.krw,
        this.kwd,
        this.lkr,
        this.mmk,
        this.mxn,
        this.myr,
        this.ngn,
        this.nok,
        this.nzd,
        this.php,
        this.pkr,
        this.pln,
        this.rub,
        this.sar,
        this.sek,
        this.sgd,
        this.thb,
        this.twd,
        this.uah,
        this.vef,
        this.vnd,
        this.zar,
        this.xdr,
        this.xag,
        this.xau,
        this.bits,
        this.sats});

  Rates.fromJson(Map<String, dynamic> json) {
    btc = json['btc'] != null ? new Btc.fromJson(json['btc']) : null;
    eth = json['eth'] != null ? new Eth.fromJson(json['eth']) : null;
    ltc = json['ltc'] != null ? new Eth.fromJson(json['ltc']) : null;
    bch = json['bch'] != null ? new Eth.fromJson(json['bch']) : null;
    bnb = json['bnb'] != null ? new Eth.fromJson(json['bnb']) : null;
    eos = json['eos'] != null ? new Eth.fromJson(json['eos']) : null;
    xrp = json['xrp'] != null ? new Eth.fromJson(json['xrp']) : null;
    xlm = json['xlm'] != null ? new Eth.fromJson(json['xlm']) : null;
    link = json['link'] != null ? new Eth.fromJson(json['link']) : null;
    dot = json['dot'] != null ? new Eth.fromJson(json['dot']) : null;
    yfi = json['yfi'] != null ? new Eth.fromJson(json['yfi']) : null;
    usd = json['usd'] != null ? new Eth.fromJson(json['usd']) : null;
    aed = json['aed'] != null ? new Eth.fromJson(json['aed']) : null;
    ars = json['ars'] != null ? new Eth.fromJson(json['ars']) : null;
    aud = json['aud'] != null ? new Eth.fromJson(json['aud']) : null;
    bdt = json['bdt'] != null ? new Eth.fromJson(json['bdt']) : null;
    bhd = json['bhd'] != null ? new Eth.fromJson(json['bhd']) : null;
    bmd = json['bmd'] != null ? new Eth.fromJson(json['bmd']) : null;
    brl = json['brl'] != null ? new Eth.fromJson(json['brl']) : null;
    cad = json['cad'] != null ? new Eth.fromJson(json['cad']) : null;
    chf = json['chf'] != null ? new Eth.fromJson(json['chf']) : null;
    clp = json['clp'] != null ? new Eth.fromJson(json['clp']) : null;
    cny = json['cny'] != null ? new Eth.fromJson(json['cny']) : null;
    czk = json['czk'] != null ? new Eth.fromJson(json['czk']) : null;
    dkk = json['dkk'] != null ? new Eth.fromJson(json['dkk']) : null;
    eur = json['eur'] != null ? new Eth.fromJson(json['eur']) : null;
    gbp = json['gbp'] != null ? new Eth.fromJson(json['gbp']) : null;
    hkd = json['hkd'] != null ? new Eth.fromJson(json['hkd']) : null;
    huf = json['huf'] != null ? new Eth.fromJson(json['huf']) : null;
    idr = json['idr'] != null ? new Eth.fromJson(json['idr']) : null;
    ils = json['ils'] != null ? new Eth.fromJson(json['ils']) : null;
    inr = json['inr'] != null ? new Eth.fromJson(json['inr']) : null;
    jpy = json['jpy'] != null ? new Eth.fromJson(json['jpy']) : null;
    krw = json['krw'] != null ? new Eth.fromJson(json['krw']) : null;
    kwd = json['kwd'] != null ? new Eth.fromJson(json['kwd']) : null;
    lkr = json['lkr'] != null ? new Eth.fromJson(json['lkr']) : null;
    mmk = json['mmk'] != null ? new Eth.fromJson(json['mmk']) : null;
    mxn = json['mxn'] != null ? new Eth.fromJson(json['mxn']) : null;
    myr = json['myr'] != null ? new Eth.fromJson(json['myr']) : null;
    ngn = json['ngn'] != null ? new Eth.fromJson(json['ngn']) : null;
    nok = json['nok'] != null ? new Eth.fromJson(json['nok']) : null;
    nzd = json['nzd'] != null ? new Eth.fromJson(json['nzd']) : null;
    php = json['php'] != null ? new Eth.fromJson(json['php']) : null;
    pkr = json['pkr'] != null ? new Eth.fromJson(json['pkr']) : null;
    pln = json['pln'] != null ? new Eth.fromJson(json['pln']) : null;
    rub = json['rub'] != null ? new Eth.fromJson(json['rub']) : null;
    sar = json['sar'] != null ? new Eth.fromJson(json['sar']) : null;
    sek = json['sek'] != null ? new Eth.fromJson(json['sek']) : null;
    sgd = json['sgd'] != null ? new Eth.fromJson(json['sgd']) : null;
    thb = json['thb'] != null ? new Eth.fromJson(json['thb']) : null;
    twd = json['twd'] != null ? new Eth.fromJson(json['twd']) : null;
    uah = json['uah'] != null ? new Eth.fromJson(json['uah']) : null;
    vef = json['vef'] != null ? new Eth.fromJson(json['vef']) : null;
    vnd = json['vnd'] != null ? new Eth.fromJson(json['vnd']) : null;
    zar = json['zar'] != null ? new Eth.fromJson(json['zar']) : null;
    xdr = json['xdr'] != null ? new Eth.fromJson(json['xdr']) : null;
    xag = json['xag'] != null ? new Eth.fromJson(json['xag']) : null;
    xau = json['xau'] != null ? new Eth.fromJson(json['xau']) : null;
    bits = json['bits'] != null ? new Btc.fromJson(json['bits']) : null;
    sats = json['sats'] != null ? new Btc.fromJson(json['sats']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.btc != null) {
      data['btc'] = this.btc.toJson();
    }
    if (this.eth != null) {
      data['eth'] = this.eth.toJson();
    }
    if (this.ltc != null) {
      data['ltc'] = this.ltc.toJson();
    }
    if (this.bch != null) {
      data['bch'] = this.bch.toJson();
    }
    if (this.bnb != null) {
      data['bnb'] = this.bnb.toJson();
    }
    if (this.eos != null) {
      data['eos'] = this.eos.toJson();
    }
    if (this.xrp != null) {
      data['xrp'] = this.xrp.toJson();
    }
    if (this.xlm != null) {
      data['xlm'] = this.xlm.toJson();
    }
    if (this.link != null) {
      data['link'] = this.link.toJson();
    }
    if (this.dot != null) {
      data['dot'] = this.dot.toJson();
    }
    if (this.yfi != null) {
      data['yfi'] = this.yfi.toJson();
    }
    if (this.usd != null) {
      data['usd'] = this.usd.toJson();
    }
    if (this.aed != null) {
      data['aed'] = this.aed.toJson();
    }
    if (this.ars != null) {
      data['ars'] = this.ars.toJson();
    }
    if (this.aud != null) {
      data['aud'] = this.aud.toJson();
    }
    if (this.bdt != null) {
      data['bdt'] = this.bdt.toJson();
    }
    if (this.bhd != null) {
      data['bhd'] = this.bhd.toJson();
    }
    if (this.bmd != null) {
      data['bmd'] = this.bmd.toJson();
    }
    if (this.brl != null) {
      data['brl'] = this.brl.toJson();
    }
    if (this.cad != null) {
      data['cad'] = this.cad.toJson();
    }
    if (this.chf != null) {
      data['chf'] = this.chf.toJson();
    }
    if (this.clp != null) {
      data['clp'] = this.clp.toJson();
    }
    if (this.cny != null) {
      data['cny'] = this.cny.toJson();
    }
    if (this.czk != null) {
      data['czk'] = this.czk.toJson();
    }
    if (this.dkk != null) {
      data['dkk'] = this.dkk.toJson();
    }
    if (this.eur != null) {
      data['eur'] = this.eur.toJson();
    }
    if (this.gbp != null) {
      data['gbp'] = this.gbp.toJson();
    }
    if (this.hkd != null) {
      data['hkd'] = this.hkd.toJson();
    }
    if (this.huf != null) {
      data['huf'] = this.huf.toJson();
    }
    if (this.idr != null) {
      data['idr'] = this.idr.toJson();
    }
    if (this.ils != null) {
      data['ils'] = this.ils.toJson();
    }
    if (this.inr != null) {
      data['inr'] = this.inr.toJson();
    }
    if (this.jpy != null) {
      data['jpy'] = this.jpy.toJson();
    }
    if (this.krw != null) {
      data['krw'] = this.krw.toJson();
    }
    if (this.kwd != null) {
      data['kwd'] = this.kwd.toJson();
    }
    if (this.lkr != null) {
      data['lkr'] = this.lkr.toJson();
    }
    if (this.mmk != null) {
      data['mmk'] = this.mmk.toJson();
    }
    if (this.mxn != null) {
      data['mxn'] = this.mxn.toJson();
    }
    if (this.myr != null) {
      data['myr'] = this.myr.toJson();
    }
    if (this.ngn != null) {
      data['ngn'] = this.ngn.toJson();
    }
    if (this.nok != null) {
      data['nok'] = this.nok.toJson();
    }
    if (this.nzd != null) {
      data['nzd'] = this.nzd.toJson();
    }
    if (this.php != null) {
      data['php'] = this.php.toJson();
    }
    if (this.pkr != null) {
      data['pkr'] = this.pkr.toJson();
    }
    if (this.pln != null) {
      data['pln'] = this.pln.toJson();
    }
    if (this.rub != null) {
      data['rub'] = this.rub.toJson();
    }
    if (this.sar != null) {
      data['sar'] = this.sar.toJson();
    }
    if (this.sek != null) {
      data['sek'] = this.sek.toJson();
    }
    if (this.sgd != null) {
      data['sgd'] = this.sgd.toJson();
    }
    if (this.thb != null) {
      data['thb'] = this.thb.toJson();
    }
    if (this.twd != null) {
      data['twd'] = this.twd.toJson();
    }
    if (this.uah != null) {
      data['uah'] = this.uah.toJson();
    }
    if (this.vef != null) {
      data['vef'] = this.vef.toJson();
    }
    if (this.vnd != null) {
      data['vnd'] = this.vnd.toJson();
    }
    if (this.zar != null) {
      data['zar'] = this.zar.toJson();
    }
    if (this.xdr != null) {
      data['xdr'] = this.xdr.toJson();
    }
    if (this.xag != null) {
      data['xag'] = this.xag.toJson();
    }
    if (this.xau != null) {
      data['xau'] = this.xau.toJson();
    }
    if (this.bits != null) {
      data['bits'] = this.bits.toJson();
    }
    if (this.sats != null) {
      data['sats'] = this.sats.toJson();
    }
    return data;
  }
}

class Btc {
  String name;
  String unit;
  int value;
  String type;

  Btc({this.name, this.unit, this.value, this.type});

  Btc.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    unit = json['unit'];
    value = json['value'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['unit'] = this.unit;
    data['value'] = this.value;
    data['type'] = this.type;
    return data;
  }
}

class Eth {
  String name;
  String unit;
  double value;
  String type;

  Eth({this.name, this.unit, this.value, this.type});

  Eth.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    unit = json['unit'];
    value = json['value'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['unit'] = this.unit;
    data['value'] = this.value;
    data['type'] = this.type;
    return data;
  }
}
