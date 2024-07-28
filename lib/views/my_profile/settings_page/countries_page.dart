import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';

class CountriesListwidget extends StatefulWidget {
  @override
  _CountriesListwidgetState createState() => _CountriesListwidgetState();
}

class _CountriesListwidgetState extends State<CountriesListwidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body:Container(
      child: CountryCodePicker(
        onChanged: print,
        // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
        initialSelection: 'IT',
        // optional. Shows only country name and flag
        showCountryOnly: false,
        // optional. Shows only country name and flag when popup is closed.
        showOnlyCountryWhenClosed: false,
        // optional. aligns the flag and the Text left
        alignLeft: false,
      ),
    ));
  }
}
