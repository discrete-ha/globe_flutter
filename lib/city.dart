class City {
  const City(
        this.name,
        this.parentid,
        this.country,
        this.woeid,
        this.countryCode
      );

  final String name;
  final int parentid;
  final String country;
  final int woeid;
  final String countryCode;

  bool contains(String query) {
    if(this.name.toLowerCase().contains(query.toLowerCase()) || this.country.toLowerCase().contains(query.toLowerCase())){
      return true;
    }
    return false;
  }
}
