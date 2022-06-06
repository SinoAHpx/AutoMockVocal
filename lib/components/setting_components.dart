import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class Expander extends StatelessWidget {
  const Expander(
      {Key? key,
      required this.header,
      required this.collapsed,
      required this.expanded})
      : super(key: key);

  final String header;

  final String collapsed;

  final Widget expanded;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Container(
      margin: const EdgeInsets.all(5),
      child: ExpandablePanel(
        header: Text(
          header,
          style: Theme.of(context).textTheme.headline5,
        ),
        collapsed: Text(
          collapsed,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        expanded: expanded,
      ),
    ));
  }
}

class SettingItem extends StatelessWidget {
  const SettingItem({
    Key? key,
    required this.input,
  }) : super(key: key);

  final Widget input;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [input],
      ),
    );
  }
}

class SettingExpander extends StatelessWidget {
  const SettingExpander(
      {Key? key,
      required this.header,
      required this.hint,
      required this.content})
      : super(key: key);

  final String header;
  final String hint;
  final List<Widget> content;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: Expander(
          header: header,
          collapsed: hint,
          expanded: Column(
            children: content,
          )),
    );
  }
}

class SettingField extends StatelessWidget {
  SettingField(
      {Key? key,
      required this.icon,
      required this.labelText,
      required this.hintText,
      required this.onChanged,
      this.controller})
      : super(key: key);

  final IconData icon;

  final String labelText;

  final String hintText;

  final Function(String) onChanged;

  TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      controller: controller,
      decoration: InputDecoration(
          icon: Icon(icon), labelText: labelText, hintText: hintText),
    );
  }
}

class SettingDropdown<T> extends StatelessWidget {
  SettingDropdown(
      {Key? key,
      required this.hintText,
      required this.labelText,
      required this.icon,
      required this.onChanged,
      required this.items,
      required this.value})
      : super(key: key);

  final String hintText;

  final String labelText;

  final IconData icon;

  final void Function(T?) onChanged;

  T? value;

  List<DropdownMenuItem<T>> items;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
        value: value,
        focusColor: Colors.transparent,
        decoration: InputDecoration(icon: Icon(icon), labelText: labelText),
        hint: Text(hintText),
        items: items,
        onChanged: onChanged);
  }
}
