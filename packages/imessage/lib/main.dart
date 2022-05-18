import 'package:flutter/cupertino.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:imessage/channel_list_view.dart';

import 'package:imessage/channel_page_appbar.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final client = StreamChatClient('tqdpjrr7us6k', logLevel: Level.INFO); //

  // For demonstration purposes. Fixed user and token.
  await client.connectUser(
    User(
      id: 'skelley',
      extraData: const {
        'image':
            'https://getstream.io/random_png/?id=cool-shadow-7&amp;name=Cool+shadow',
      },
    ),
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoic2tlbGxleSJ9.rCNQoUcATdYKLZ2R0GtL7QHKh1_lI_a7FwqAAAgy1_g',
  );

  runApp(IMessage(client: client));
}

class IMessage extends StatelessWidget {
  const IMessage({Key? key, required this.client}) : super(key: key);

  final StreamChatClient client;

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('en_US', null);
    return CupertinoApp(
      title: 'The Exchange',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(brightness: Brightness.light),
      home: StreamChatCore(client: client, child: ChatLoader()),
    );
  }
}

class ChatLoader extends StatelessWidget {
  ChatLoader({
    Key? key,
  }) : super(key: key);

  final channelListController = ChannelListController();

  @override
  Widget build(BuildContext context) {
    final user = StreamChatCore.of(context).currentUser!;
    return CupertinoPageScaffold(
      child: ChannelsBloc(
        child: ChannelListCore(
          channelListController: channelListController,
          filter: Filter.and([
            Filter.in_('members', [user.id]),
            Filter.equal('type', 'messaging'),
          ]),
          sort: const [SortOption('last_message_at')],
          limit: 20,
          emptyBuilder: (BuildContext context) {
            return const Center(
              child: Text('Looks like you are not in any channels'),
            );
          },
          loadingBuilder: (BuildContext context) {
            return const Center(
              child: SizedBox(
                height: 100.0,
                width: 100.0,
                child: CupertinoActivityIndicator(),
              ),
            );
          },
          errorBuilder: (BuildContext context, dynamic error) {
            return const Center(
              child: Text(
                  'Oh no, something went wrong. Please check your config.'),
            );
          },
          listBuilder: (
            BuildContext context,
            List<Channel> channels,
          ) =>
              LazyLoadScrollView(
            onEndOfPage: () async {
              return channelListController.paginateData!();
            },
            child: CustomScrollView(
              slivers: [
                CupertinoSliverRefreshControl(onRefresh: () async {
                  return channelListController.loadData!();
                }),
                const ChannelPageAppBar(),
                SliverPadding(
                  sliver: ChannelListView(channels: channels),
                  padding: const EdgeInsets.only(top: 16),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
