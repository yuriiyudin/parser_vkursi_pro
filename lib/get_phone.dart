import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

Future<String?> getFirstPhone({required String uid, required String edrpou}) async {
  var url = Uri.parse('https://vkursi.pro/card/getcontacts?organizationId=$uid&edrpou=$edrpou');

// A string with cookies that you want to add to the request

 // Create an HTTP GET request with cookies
  Response? response;

  try {
    response = await http.get(url, headers: {
      // 'Cookie': cookies,
      'authority': 'vkursi.pro',
      'accept': '*/*',
      'accept-language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
      'cookie':
          '_gcl_au=1.1.1083389093.1708535579; _gid=GA1.2.1855995054.1708535580; _fbp=fb.1.1708535579723.353657450; _hjSessionUser_1763197=eyJpZCI6ImE2ODkzOGMyLTNmMTktNTU3Zi1iNWQ0LTUwYzMwYzFjNTI5YyIsImNyZWF0ZWQiOjE3MDg1MzU1Nzk4OTksImV4aXN0aW5nIjp0cnVlfQ==; _ga_S4ZGDWTSX5=deleted; _clck=1aba040%7C2%7Cfji%7C0%7C1512; TiPMix=67.07606663725755; x-ms-routing-name=self; .AspNetCore.Antiforgery.prrXXfN7jAM=CfDJ8LjGW4hB551MonX_C43-VOHICgKjmFIhg5MZCYfEIBcjGuyb-Bh2WL5HyNresonVbtQsXkztGKtySvSzk2lZe7C1JT7b-087llSMkalCgyrOWZkjsqZTpLl5vtT2_ztIMcd58Tw0ePKBD_FqydC0V5M; _gat=1; _hjSession_1763197=eyJpZCI6IjU3NjE4OThkLWMzN2QtNDQ1My1iM2I2LWQ5MDM0NzFlNGUxYyIsImMiOjE3MDg3MDY3NDExMzksInMiOjAsInIiOjAsInNiIjowLCJzciI6MCwic2UiOjAsImZzIjowLCJzcCI6MH0=; _ga_S4ZGDWTSX5=GS1.1.1708706739.15.1.1708706772.27.0.0; _ga=GA1.1.737627886.1708535580; _clsk=vhowwg%7C1708706773242%7C2%7C1%7Cr.clarity.ms%2Fcollect; .AspNetCore.Identity.Application=CfDJ8LjGW4hB551MonX_C43-VOGTqfY0hGgR-Q7x8UTWNYuPcvMEv6MhddWwkGLxytMj_OGim-RsAE9i5qeFMY13sW0p_FHDcCWT9jtcMJIF50rwECkvpw0a_MYVBLCklS1smr8lYm7b4QfKooVJ37lipEA7-SCfvGXjY_c5KCoJKixU9qDAJSbgAAPCRPubutU6plrZoOBdW0-wJyGq-YuW8H0Q5n4j5PW2WLvscYYic061e2-bdcYJxl8G2vC3aHeia_pv90u_Fxezs0VY8odZC7TjJft_LXLUdr16px3UL3Y4fYqm7POFKnHBEiAJSETd2ge3uDDT0GppkWqBnvSiIsg42_l1yCd91TXWESRKFIadoyE2CkS0RvNLNGqRarqHoG0-jLbB29BbHgc4gTNwOd5_4xTyMJRI9ZsejP4cEAjrvmdecFSql7ArLJk6_OaXZjphzSn2tARYCxjY3iFGqtmFUhr94NdXJCiu_DwpRBVuja03oe8gzuhgWHotfk3H6CPlxIMzq18I4CMSbB5y189rNPnbjRIQLc8UqOBbdpNY7LTHcJKmqqS1Wia1I4LwBHKhSLaVXls6J1uwv3BDiBj_QGSHUcLHWMXAr6ET2vetviA9SOXrgh9TEBtFvnSLk2PlWE6rENLJFgLjDfNsI25GnhnjG0ipOB3IOScXBeWuCBswm-dBvOnR8g3bqb_RXoVGtKkg5AO5TqEuFlBXuZoyLNDOTl_Tv3tgNNhb5opZPNKMcKrIOXPCUoI9SDXhH0nl3FfVyVe5iXhTvfhZyNET0uhVkA9_6zocEUq-9JlUgFl5JrLdFjsCovAYDrLsQGbFDZf1n9yQpJKhWL39sUI',
      'referer': 'https://vkursi.pro/card/tov-bla-bla-bar-kyiv-43080503',
      'sec-ch-ua': '"Not A(Brand";v="99", "Google Chrome";v="121", "Chromium";v="121"',
      'sec-ch-ua-mobile': '?0',
      'sec-ch-ua-platform': '"Windows"',
      'sec-fetch-dest': 'empty',
      'sec-fetch-mode': 'cors',
      'sec-fetch-site': 'same-origin',
      'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
      'Accept-Encoding': 'gzip',
    });
  } catch (e) {
    print('error');
    print(e);
    return null;
  }

  try {
    if (response.statusCode == 200) {
      final phonesList = [];

      final data = (jsonDecode(response.body)['tenderList'] as List<dynamic>)[0];


      data.forEach((key, value) {
  
        if (key == "phones") {
          phonesList.add(value);
        }
      });

      final phone = phonesList.join(',');
      if (phone.length > 4) {
        return phone;
      } else {
        return null;
      }
    }
  } catch (e) {
    print('no first phone at header');

  }
}
