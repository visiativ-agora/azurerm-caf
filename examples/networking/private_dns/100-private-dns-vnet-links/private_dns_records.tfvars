
# If you need to reference an existing DNS private dns zone, the following structure must be used
private_dns_records = {
  pvdns1 = {
    resource_group = {
        # lz_key = ""
        key = "private_dns_region1"
    }
    private_dns = {
        # lz_key = "name of the remote landingzone"
        key = "dns1"
    }

    records = {
      a = {
        test = {
          name    = "test.priv"
          ttl     = 3600
          records = ["3.3.3.3", "4.4.4.4"]
        }
      }
    }
  }
}