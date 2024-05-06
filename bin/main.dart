import 'dart:io';
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:excel/excel.dart';
import 'package:http/http.dart';
import 'package:pool/pool.dart';
import 'package:pool_vkursi/config.dart';
import 'package:pool_vkursi/get_id.dart';
import 'package:pool_vkursi/get_phone.dart';
import 'package:pool_vkursi/models/company_model.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

int total = 54996;

void main() async {
  var pool = Pool(20); // Pool to limit concurrent operations
  var fileForRead = 'lib/codes2.xlsx';
  var bytesForRead = File(fileForRead).readAsBytesSync();
  var excelForRead = Excel.decodeBytes(bytesForRead);
  List<Future<Company?>> tasks = [];


  Future<Company?> parse(CellValue cellValue) async {
    total--;
    final url = Uri.parse('https://vkursi.pro/card/${cellValue.toString()}').replace(queryParameters: params);

    Response? res;
    try {
      res = await http.get(url, headers: headers);
    } catch (e) {
      return null;
    }

    final status = res.statusCode;
    if (status != 200) {
      print('no such link ${res.statusCode}');
      return null;
    }


    BeautifulSoup soup = BeautifulSoup(res.body);
    final blocks = soup.find('div', class_: 'td-value td td-contacts')?.findAll('p'); //adress block elemets
    final blockHeadersContacts = soup.find('div', class_: 'contact-header-preview'); // headers firstphones

    final shortName = soup.find('h1', class_: 'title')?.text.trim() ?? '';

    String? firstPhones;

    try {
      final uid = await getUid(edrpou: cellValue.toString());

      firstPhones = await getFirstPhone(uid: uid!, edrpou: cellValue.toString());
      print(firstPhones);
    } catch (e) {
      print('error');
      print(e);
    }

    final email = blocks?.map((e) => e.text).toList().firstWhere((element) => element.contains('@'), orElse: () => '') ?? '';

    final website = blocks
            ?.map((e) => e.text)
            .toList()
            .firstWhere((element) => ['www', 'WWW', 'http', 'https', 'HTTP', 'HTTPS'].any((subString) => element.contains(subString)), orElse: () => '') ??
        '';

    final statuCompany = soup.find('div', id: 'status')?.text.trim() ?? '';
    final bankrot = soup.find('div', id: 'bankrut-top')?.text.trim() ?? '';
    final stoped = soup.find('div', id: 'reorganization-top')?.text.trim() ?? '';
    final codeEdrpoy = soup.find('div', class_: 'tr', string: 'Код ЄДРПОУ')!.find('div', class_: 'td-value')?.text.trim() ?? '';
    final fullName = soup.find('div', id: 'org-name')?.text.trim() ?? '';
    final type = soup.find('div', class_: 'tr', string: 'Організаційно-правова форма')?.find('div', class_: 'td-value')!.text.trim() ?? '';
    final dateRegistered = soup.find('div', class_: 'info-row')?.text.replaceFirst('Дата державної реєстрації:', '').trim() ?? '';

    final badDataZapisu = soup.find('div', class_: 'regs-item__info')?.findAll('div', class_: 'info-row')[1].text.trim() ?? '';
    RegExp dateRegExp = RegExp(r'\b\d{2}\.\d{2}\.\d{4}\b');
    final dataZapisu = dateRegExp.firstMatch(badDataZapisu)?.group(0) ?? '';

    final baDnumberZapisu = soup.find('div', class_: 'regs-item__info')?.findAll('div', class_: 'info-row')[1].text.trim() ?? '';
    RegExp numberRegExp = RegExp(r'.{18}$');
    final numberZapisu = numberRegExp.firstMatch(baDnumberZapisu)?.group(0) ?? '';

    final adress = blocks?.first.text.trim() ?? '';

    final secondPhones = blocks
        ?.sublist(1)
        .map((e) {
     // Extract all phone number matches from a string
          var matches = RegExp(r'\+38\(\d{3}\)-\d{3}-\d{2}-\d{2}').allMatches(e.text);
          if (matches.isNotEmpty) {
   // Convert each match to a string and combine them into a list
            return matches.map((m) => m.group(0)).join(', ');
          } else {
            return '';
          }
        })
        .where((e) => e.isNotEmpty)
        .toList();

    final owner = soup.find('a', class_: 'head-name')?.text.trim() ?? '';
    final kvedMain = soup.find('p', class_: 'td-kveds__main')?.text.trim() ?? '';
    final kvedDop = soup
            .find('div', class_: 'td-value td td-kveds scroll')
            ?.text
            .trim()
            .replaceFirst(kvedMain, '')
            .replaceFirst('КВЕД за вашим запитом не знайдено', '')
            .trim() ??
        '';
    final taxesData = soup
            .find('div', class_: 'tr', string: 'Дані про реєстраційний номер платника єдиного внеску')!
            .find('div', class_: 'td-value td')
            ?.text
            .replaceFirst('Інформація відсутня', '')
            .trim() ??
        '';

    Company company = Company(
        shortName: shortName,
        firstPhones: firstPhones ?? '',
        email: email,
        website: website,
        status: statuCompany,
        bankrot: bankrot,
        stoped: stoped,
        codeEdrpoy: codeEdrpoy,
        fullName: fullName,
        type: type,
        dateRegistered: dateRegistered,
        dataZapisu: dataZapisu,
        numberZapisu: numberZapisu,
        adress: adress,
        secondPhones: secondPhones,
        owner: owner,
        kvedMain: kvedMain,
        kvedDop: kvedDop,
        taxesData: taxesData);

    return company;
  }



  for (var table in excelForRead.tables.keys) {

    var sheet = excelForRead.tables[table];

    // Iterate through each row in the sheet
    for (var row in sheet!.rows) {
      var cellValue = row[0]?.value; // Get the value of the first cell in the row
      if (cellValue.toString().length == 8) {
        var task = pool.withResource(() => (parse(cellValue!)));
        tasks.add(task);
      }
    }
    print('lets break');
    break;
  }

  var companiess = await Future.wait(tasks);

  var companiesList = companiess.whereType<Company>().toList();


  var filePath = p.join(Directory.current.path, 'Парсинг+підприємства.xlsx');
  var file = File(filePath);

  Excel excel;

  if (file.existsSync()) {
    var bytes = file.readAsBytesSync();

    excel = Excel.decodeBytes(bytes);
  } else {
    ;
    excel = Excel.createExcel();
  }

  var sheetName = 'Юридичні особи';

  var sheet = excel!.sheets[sheetName];

  companiesList.forEach((company) {
    int lastRow = sheet!.maxRows;

    var companyShortName = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: lastRow));
    companyShortName.value = TextCellValue(company!.shortName);

    var companyFirstPhones = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: lastRow));
    companyFirstPhones.value = TextCellValue(company.firstPhones);

    var companyEmail = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: lastRow));
    companyEmail.value = TextCellValue(company.email);

    var companyWebsite = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: lastRow));
    companyWebsite.value = TextCellValue(company.website);

    var companyStatus = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: lastRow));
    companyStatus.value = TextCellValue(company.status);

    var companyBankrot = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: lastRow));
    companyBankrot.value = TextCellValue(company.bankrot);

    var companyStoped = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: lastRow));
    companyStoped.value = TextCellValue(company.stoped);

    var companycodeEdrpoy = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: lastRow));
    companycodeEdrpoy.value = TextCellValue(company.codeEdrpoy);

    var companyfullName = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: lastRow));
    companyfullName.value = TextCellValue(company.fullName);

    var companyType = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: lastRow));
    companyType.value = TextCellValue(company.type);

    var companyDateRegistered = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: lastRow));
    companyDateRegistered.value = TextCellValue(company.dateRegistered);

    var companyDataZapisu = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: lastRow));
    companyDataZapisu.value = TextCellValue(company.dataZapisu);

    var companyNumberZapisu = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: lastRow));
    companyNumberZapisu.value = TextCellValue(company.numberZapisu);

    var companyAdress = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: lastRow));
    companyAdress.value = TextCellValue(company.adress);

    var companysecondPhones = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 14, rowIndex: lastRow));
    companysecondPhones.value = TextCellValue(company.secondPhones?.join(',').replaceFirst(',', '').replaceFirst(',,', '') ?? '');

    var companyOwner = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 15, rowIndex: lastRow));
    companyOwner.value = TextCellValue(company.owner);

    var companyKvedMain = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 16, rowIndex: lastRow));
    companyKvedMain.value = TextCellValue(company.kvedMain);

    var companyKvedDop = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 17, rowIndex: lastRow));
    companyKvedDop.value = TextCellValue(company.kvedDop);

    var companyTaxesData = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 18, rowIndex: lastRow));
    companyTaxesData.value = TextCellValue(company.taxesData);
  });

  List<int>? fileBytes = excel.save();

  File(filePath).writeAsBytes(fileBytes!);
}
