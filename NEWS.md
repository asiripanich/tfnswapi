# tfnswapi 0.3.0

* Added the ability to specific which protobuf descriptor `tfnswapi_get()` will use to parse a 'application/x-google-protobuf' response. You can select one of `transit_realtime.*` variables, `transit_realtime.FeedMessage` is selected as default.

# tfnswapi 0.2.0

* You now can quickly browse TfNSW API with `tfnswapi_browse()`.
* `tfnswapi_get()` is now able to parse 'application/x-google-protobuf', the protobuf format of GTFS realtime.

# tfnswapi 0.1.0

* Added a `NEWS.md` file to track changes to the package.
