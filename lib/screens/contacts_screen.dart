import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phishingblock/helper/utils.dart';
import 'package:phishingblock/provider/contacts_provider.dart';
import 'package:phishingblock/router/router.dart';
import 'package:phishingblock/widgets/contact_item.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  TextEditingController searchController = TextEditingController();
  final contactProvider = Get.find<ContactsProvider>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("연락처"),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(8),
            child: TextField(
              controller: searchController,
              onChanged: (e) => setState(() {}),
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                suffixIcon: const Icon(Icons.search),
                suffixStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                hintText: "검색어를 입력하세요.",
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: const Color(0xFFEEEFFF),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: contactProvider.rxNameKeyContacts.length,
              itemBuilder: (context, index) {
                String searchText = searchController.text;
                (String, String) data = (
                  contactProvider.keyList[index],
                  contactProvider
                      .rxNameKeyContacts[contactProvider.keyList[index]]!
                );
                String sender = data.$2.replaceAll("-", "");

                //검색어가 비어있으면 모두 출력
                if (searchText == "") {
                  return InkWell(
                    onTap: () {
                      router.pop();
                      router.pushNamed(Screen.detail, extra: {
                        "name": data.$1,
                        "sender": sender,
                      });
                    },
                    child: ContactItem(data: data),
                  );
                }
                //검색어가 있으면,
                else {
                  //검색어가 초성이면 초성 검색
                  if (Utils.isEntirelyChosung(searchText)) {
                    if (Utils.containsSearch(data.$1, searchText)) {
                      return InkWell(
                        onTap: () {
                          router.pop();
                          router.pushNamed(Screen.detail, extra: {
                            "name": data.$1,
                            "sender": sender,
                          });
                        },
                        child: ContactItem(data: data),
                      );
                    }
                  }
                  //아니면 단어 검색
                  else {
                    if (data.$1.contains(searchText)) {
                      return InkWell(
                        onTap: () {
                          router.pop();
                          router.pushNamed(Screen.detail, extra: {
                            "name": data.$1,
                            "sender": sender,
                          });
                        },
                        child: ContactItem(data: data),
                      );
                    }
                  }
                }
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }
}
