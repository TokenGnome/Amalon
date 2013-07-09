var GOOD = ( 2 | 8 | 32 ),
    EVIL = ( 4 | 16 | 64 | 128 | 256 ),
    FAVORABLE = [10, 20, 40, 80, 100],
    UNFAVORABLE = [0, 5, 10, 50, 100],
    OPPOSED = [0, 0, 5, 5, 100],
    ACCEPTED = [80, 85 ,95, 100, 100],
    RANKS = [0, 10, 20, 40, 80, 100];


var rand = function(min, max) {
	return Math.floor((Math.random() * max) + min);
};

var vote = function(voteNumber, table) {
    return rand(0, 100) < table[voteNumber-1];
};

var rank = function(start, finish) {
    return rand(RANKS[start], RANKS[finish]);
};

var currentPlayer = function(state) {
    return state.observer;
};

var playerIsGood = function(player) {
    return (player.role.type & GOOD) !== 0;
};

var playerIsEvil = function(player) {
    return (player.role.type & EVIL) !== 0;
};

var numberOfSpysOnQuest = function(quest) {
    return quest.currentProposal.players
        .filter(function(player) { return playerIsEvil(player); })
        .length;
};

var proposeQuest = function(size, state) {

    var me = currentPlayer(state),
        amEvil = playerIsEvil(me),
        players = state.players.slice(0);

    return players.map(function(p) { 
        var score;
        if (amEvil && playerIsEvil(p)) score = rank(0, 2);
        else if (!amEvil && playerIsGood(p)) score = rank(4, 5);
        else score = rank(0, 5);
        return [p.playerId, score]; })
    .sort(function(p1, p2) {
        return p2[1] - p1[1]; })
    .map(function(p) {
        return p[0];
    })
    .slice(0, size);
};

var acceptProposal = function(state) {
    if (state.voteNumber === 5) return true;

    var me = currentPlayer(state),
        knownSpyCount = numberOfSpysOnQuest(state.currentQuest),
        amEvil = playerIsEvil(me),
        n = state.voteNumber,
        table;

    if (amEvil) {
        table = knownSpyCount > 0 ? FAVORABLE : UNFAVORABLE;
    } else {
        table = knownSpyCount > 0 ? OPPOSED : FAVORABLE;
    }

    return vote(n, table);
};

var passQuest = function(state) {
    var me = currentPlayer(state),
        amEvil = playerIsEvil(me),
        fr = state.currentQuest.failsRequired,
        p = state.passedQuestCount,
        f = state.failedQuestCount;

    if (amEvil) {
        if (fr < 2 && f > 1) return false;
        if (fr < 2 && me.role.type !== 64 && p < 2) return false;
    } 
    return true;
};

var assassinatePlayer = function(state) {
	return state.players[rand(0, state.players.length-1)].playerId
};

var dumpState = function(state) {
	return JSON.stringify(state);
};

var dumpPlayer = function(state) {
    return JSON.stringify(currentPlayer(state));
};