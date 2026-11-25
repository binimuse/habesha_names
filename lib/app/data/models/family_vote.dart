import '../../core/utils/labels.dart';
import 'name_model.dart';

/// One choice on a family vote (a snapshot, so the web page needs no app data).
class VoteOption {
  const VoteOption({
    required this.nameId,
    required this.latin,
    required this.geez,
    this.meaning = '',
  });

  factory VoteOption.fromName(NameModel n) => VoteOption(
    nameId: n.id,
    latin: n.nameLatin,
    geez: n.nameGeez,
    meaning: Labels.meaning(n),
  );

  factory VoteOption.fromJson(Map<String, dynamic> j) => VoteOption(
    nameId: j['name_id'] as String,
    latin: j['latin'] as String? ?? '',
    geez: j['geez'] as String? ?? '',
    meaning: j['meaning'] as String? ?? '',
  );

  final String nameId;
  final String latin;
  final String geez;
  final String meaning;

  Map<String, dynamic> toJson() => {
    'name_id': nameId,
    'latin': latin,
    'geez': geez,
    'meaning': meaning,
  };
}

/// `votes/{id}`.
class FamilyVote {
  const FamilyVote({
    required this.id,
    required this.ownerUid,
    required this.title,
    required this.options,
    required this.open,
    required this.createdAt,
  });

  factory FamilyVote.fromJson(String id, Map<String, dynamic> j) => FamilyVote(
    id: id,
    ownerUid: j['owner_uid'] as String? ?? '',
    title: j['title'] as String? ?? '',
    options: [
      for (final Object? o in j['options'] as List<Object?>? ?? const [])
        VoteOption.fromJson(Map<String, dynamic>.from(o! as Map)),
    ],
    open: j['open'] as bool? ?? false,
    createdAt: j['created_at'] is DateTime
        ? j['created_at'] as DateTime
        : DateTime.now(),
  );

  static const int minOptions = 2;
  static const int maxOptions = 6;

  final String id;
  final String ownerUid;
  final String title;
  final List<VoteOption> options;
  final bool open;
  final DateTime createdAt;
}

/// `votes/{id}/ballots/{voterUid}` — doc id = the voter's (anonymous) uid,
/// which is what limits voting to one ballot per device.
class Ballot {
  const Ballot({
    required this.voterId,
    required this.voterName,
    required this.choice,
  });

  final String voterId;
  final String voterName;

  /// The chosen option's name id.
  final String choice;
}

class OptionTally {
  const OptionTally(this.option, this.votes, this.voters);

  final VoteOption option;
  final int votes;
  final List<String> voters;
}

/// Live results: per-option counts, highest first (ties keep option order).
class VoteTally {
  VoteTally(FamilyVote vote, List<Ballot> ballots)
    : total = ballots
          .where((b) => vote.options.any((o) => o.nameId == b.choice))
          .length,
      options = _tally(vote, ballots);

  final int total;
  final List<OptionTally> options;

  /// Name ids with the most votes (empty when nobody voted).
  Set<String> get leaders {
    if (total == 0) return const {};
    final int top = options.first.votes;
    return {
      for (final o in options)
        if (o.votes == top) o.option.nameId,
    };
  }

  static List<OptionTally> _tally(FamilyVote vote, List<Ballot> ballots) {
    final List<OptionTally> list = [
      for (final VoteOption o in vote.options)
        OptionTally(o, ballots.where((b) => b.choice == o.nameId).length, [
          for (final Ballot b in ballots)
            if (b.choice == o.nameId) b.voterName,
        ]),
    ];
    final List<int> order = List.generate(list.length, (i) => i)
      ..sort((a, b) {
        final int v = list[b].votes.compareTo(list[a].votes);
        return v != 0 ? v : a.compareTo(b);
      });
    return [for (final int i in order) list[i]];
  }
}
