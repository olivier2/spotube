import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/components/settings/section_card_with_heading.dart';
import 'package:spotube/extensions/context.dart';
import 'package:spotube/provider/user_preferences/user_preferences_provider.dart';

class SettingsProxySection extends HookConsumerWidget {
  const SettingsProxySection({Key? key}) : super(key: key);
  static String socksFormat = "SOCKS5/SOCKS4/PROXY username:password@host:port";

  String? validateProxy(BuildContext context, String value) {
    final socksMatcher =
        RegExp(r'^(SOCKS5|SOCKS4|PROXY) ([^:]+:[^@]+@)?[^:]+:[\d]+');
    if (value.isNotEmpty && !socksMatcher.hasMatch(value)) {
      return context.l10n.proxyValidationHelp + socksFormat;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, ref) {
    final preferencesNotifier = ref.watch(userPreferencesProvider.notifier);
    final controller =
        useTextEditingController(text: preferencesNotifier.getSocksProxy());

    useListenable(controller);
    useEffect(() {
      return () {
        controller.dispose();
      };
    }, []);

    return SectionCardWithHeading(
      heading: context.l10n.proxy,
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
              hintText: socksFormat,
              errorText: validateProxy(context, controller.text),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        controller.clear();
                        preferencesNotifier.setSocksProxy("");
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null),
          onChanged: (value) async {
            if (validateProxy(context, controller.text) == null) {
              preferencesNotifier.setSocksProxy(controller.text);
            }
          },
        ),
      ],
    );
  }
}
