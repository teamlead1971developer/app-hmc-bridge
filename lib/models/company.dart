/// Corporate entities available at sign-in.
enum Company {
  hmc(1, 'HMC'),
  aton(2, 'ATON'),
  haagon(3, 'HAAGON'),
  karim(4, 'KARIM'),
  hg(5, 'HG'),
  overjoy(6, 'OVERJOY'),
  wondrous(7, 'WONDROUS'),
  tht(8, 'THT'),
  hmcShop(9, 'HMC_SHOP');

  const Company(this.id, this.label);

  final int id;
  final String label;

  static Company? fromId(int id) {
    for (final company in Company.values) {
      if (company.id == id) return company;
    }
    return null;
  }

  static Company get defaultCompany => Company.hmc;
}
