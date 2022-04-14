.onLoad <- function(libname, pkgname) {
  proto.dir <- system.file("proto", package = "tfnswapi", mustWork = T)
  proto.file <- file.path(proto.dir, "gtfs-realtime.proto")
  RProtoBuf::readProtoFiles(proto.file)
}
