
var rand = function(min, max) {
	return Math.floor((Math.random() * max) + min);
}

var proposeQuest = function(state) {
	var start = rand(0, size-1)
      , size = state.currentQuest.playerCount;
	return state.players
	.slice(start, start+size)
	.map(function(player) { return player.playerId; });
};

var acceptProposal = function(state) {
	return true;
};

var passQuest = function(state) {
	return true;
};

var assassinatePlayer = function(state) {
	return state.players[rand(0, state.players.length-1)].playerId
};

var dumpState = function(state) {
	return JSON.stringify(state);
};