import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/settings/settings_bloc.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/core/strings.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:fluxtube/widgets/widgets.dart';

class ScreenInstances extends StatelessWidget {
  const ScreenInstances({super.key});

  @override
  Widget build(BuildContext context) {
    final locals = S.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(locals.instances),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(
                text: 'Piped',
              ),
              Tab(
                text: 'Invidious',
              ),
            ],
          ),
        ),
        body: const SafeArea(
          child: TabBarView(
            children: [
              PipedInstanceListView(),
              InvidiousInstanceListView(),
            ],
          ),
        ),
      ),
    );
  }
}

class PipedInstanceListView extends StatelessWidget {

  const PipedInstanceListView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<SettingsBloc>(context)
          .add(SettingsEvent.fetchPipedInstances());
    });
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state.pipedInstanceStatus == ApiStatus.loading ||
            state.pipedInstanceStatus == ApiStatus.initial) {
          return Center(child: cIndicator(context));
        }

        final instances = state.pipedInstances.toList();

        return ListView.separated(
          itemBuilder: (context, index) => ListTile(
            onTap: () async {
              BlocProvider.of<SettingsBloc>(context).add(
                SettingsEvent.setInstance(instanceApi: instances[index].api),
              );

              BaseUrl.kBaseUrl = instances[index].api;
            },
            leading: state.instance == instances[index].api
                ? const Icon(CupertinoIcons.check_mark)
                : null,
            title: Text(
              instances[index].name,
              textAlign: TextAlign.left,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontSize: 16),
            ),
            subtitle: Text(
              instances[index].locations.replaceAll(',', ' '),
              textAlign: TextAlign.left,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontSize: 16),
            ),
          ),
          separatorBuilder: (context, index) => const SizedBox(),
          itemCount: instances.length,
        );
      },
    );
  }
}

class InvidiousInstanceListView extends StatelessWidget {

  const InvidiousInstanceListView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<SettingsBloc>(context)
          .add(SettingsEvent.fetchInvidiousInstances());
    });
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state.invidiousInstanceStatus == ApiStatus.loading ||
            state.invidiousInstanceStatus == ApiStatus.initial) {
          return Center(child: cIndicator(context));
        }

        final instances = state.invidiousInstances.toList();

        return ListView.separated(
          itemBuilder: (context, index) => ListTile(
            onTap: () async {
              BlocProvider.of<SettingsBloc>(context).add(
                SettingsEvent.setInstance(instanceApi: instances[index].api),
              );

              BaseUrl.kBaseUrl = instances[index].api;
            },
            leading: state.instance == instances[index].api
                ? const Icon(CupertinoIcons.check_mark)
                : null,
            title: Text(
              instances[index].name,
              textAlign: TextAlign.left,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontSize: 16),
            ),
            subtitle: Text(
              instances[index].locations.replaceAll(',', ' '),
              textAlign: TextAlign.left,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontSize: 16),
            ),
          ),
          separatorBuilder: (context, index) => const SizedBox(),
          itemCount: instances.length,
        );
      },
    );
  }
}
