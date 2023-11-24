#!/usr/bin/env awk -f
# generates wireguard server/peer config
# assumes 1+NUMPEERS usable IPs in subnet
# does not account for postup/predown

### BGN Configuration section ###
BEGIN{ # config options go here
  GATEWAY="10.99.99.1" # Server IFace IP (GW)
  LISTEN_PORT=51820 # shared for server/peer
  NUMPEERS=5
  ENDPOINT="example.com" # can be IP
  #DNS="1.1.1.1" # DNS is optional, uncomment to use

  # GO GO GO
  for (i=1;i<=NUMPEERS;i++) PeerConfig[i]=""
  GenerateConfigs()
}
### END Configuration section ###

### BGN Key Generation ###
function WGKey(Cmd){
  Cmd|getline; Key=$0;
  close(Cmd); return Key
}
function GenKey(){
  return WGKey("wg genkey")
}
function PubKey(PrivKey){
  return WGKey(sprintf("wg pubkey <<< \"%s\"",PrivKey))
}
function GenPsk(){
  return WGKey("wg genpsk")
}
### END Key Generation ###

### BGN Server/Peer Config ###
function GenerateConfigs(){
  SKey=GenKey(); SPub=PubKey(SKey)
  Interface(SKey)
  GenPeers(NUMPEERS,SPub)
  print ""
  for (i=1;i<=NUMPEERS;i++){
    print ""
    split(PeerConfig[i],P,"#")
    GenPeerConfig(i,P[1],P[2],P[3],P[4])
  }
}
function Interface(SKey){
  print "############################"
  print "### BGN Interface Config ###"
  print "############################"
  print "[Interface]"
  print "Address = "GATEWAY
  print "PrivateKey = "SKey
  print "ListenPort = "LISTEN_PORT
  print "Table = off"
}
function Peer(PeerNum,PeerAIP,PPub,PPsk){
  print ""
  print "[Peer] # Peer "PeerNum
  print "PublicKey = "PPub
  print "PreSharedKey = "PPsk
  print "AllowedIPs = "PeerAIP
}
function GenPeerConfig(PNum,PKey,PPsk,PeerAIP,SPub){
  print "#########################"
  print "### BGN Peer "PNum" config ###"
  print "#########################"
  print "[Interface] # Peer "PNum
  print "Address = "PeerAIP
  print "PrivateKey = "PKey
  print "ListenPort = "LISTEN_PORT
  if (length(DNS)>0) print "DNS = "DNS
  print "Table = off"
  print ""
  print "[Peer]"
  print "PublicKey = "SPub
  print "PreSharedKey = "PPsk
  print "AllowedIPs = 0.0.0.0/0"
  print "EndPoint = "ENDPOINT":"LISTEN_PORT
  print "#########################"
  print "### END Peer "PNum" config ###"
  print "#########################"
}
function GenPeers(NumPeers,SPub){
  for (i=1;i<=NumPeers;i++){
    PKey=GenKey(); PPub=PubKey(PKey); PPsk=GenPsk()
    split(GATEWAY,O,"."); PeerAIP=sprintf("%d.%d.%d.%d/32",\
      O[1],O[2],O[3],O[4]+i)
    Peer(i,PeerAIP,PPub,PPsk)
    PeerConfig[i]=sprintf("%s#%s#%s#%s",PKey,PPsk,PeerAIP,SPub)
  }
  print "############################"
  print "### END Interface Config ###"
  print "############################"
}
### END Server/Peer Config ###
