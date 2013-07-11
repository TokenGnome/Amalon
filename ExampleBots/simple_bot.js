var rand = function(min, max) {
    return Math.floor((Math.random() * max) + min);
};

var vote = function(chance) {
    return rand(0, 100) < chance;
};

var _MerlinOrMorgana = 136
, _Good = 42
, _GoodOrOberon = 298
, _GoodOrMordred = 106
, _EvilNotMordred = 404
, _EvilNotOberon = 212
, _Evil = 468;

var hasOberon = function(roles) {
    return roles.filter(function(role) { return role.type === 256 }).length > 0;
};

var numSpys = function(roles) {
    return roles.filter(function(role) { return (role.type & _Evil) !== 0 }).length
};

var amGood = function(state) {
    return (state.observer.role.type & _Good) !== 0;
};

var baseProbability = function(player, state) {
    if (player.role.type === _MerlinOrMorgana) return 0.5;
    if (player.role.type === _GoodOrOberon) return hasOberon(state.roles) ? (state.players.length - 1) / state.players.length : 1;
    if (player.role.type === _GoodOrMordred) return (state.players.length - 1) / state.players.length;
    if (player.role.type === _EvilNotMordred) return 0;
    if (player.role.type === _EvilNotOberon) return 0;
    return (state.players.length - numSpys(state.roles)) / state.players.length;
};

var avgProbability = function(players, state) {
    var probs = players.map(function(player) { return baseProbability(player, state); });
    var sum = probs.reduce(function(prev, curr, id, arr) { return prev + curr; }, 0);
    return  sum / players.length;
};

var proposeQuest = function(state) {
    return state.players.map(function(player) {
                             return [player.playerId, baseProbability(player, state)];
                             }).sort(function(p1, p2) {
                                     return p2[1] - p2[0];
                                     }).map(function(p) {
                                            return p[0];
                                            }).slice(0, state.currentQuest.playerCount);
};

var acceptProposal = function(state) {
    if (state.voteNumber === 5) return true;
    if (amGood(state)) return avgProbability(state.currentQuest.currentProposal.players, state) > 0.5;
    return vote(30);
};

var passQuest = function(state) {
    return amGood(state);
};

var assassinatePlayer = function(state) {
    var pool = state.players.filter(function(player) {
                                    return (player.role.type & _Good !== 0);
                                    });
    return pool[rand(0, pool.length-1)].playerId;
};