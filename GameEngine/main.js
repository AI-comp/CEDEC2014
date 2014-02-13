// Generated by CoffeeScript 1.7.1
(function() {
  var EvalPlayer, Player, createPlayer, history, process;

  history = [];

  EvalPlayer = (function() {
    function EvalPlayer(code, pid) {
      this.pid = pid;
      eval(code);
      this.command = program;
      this.id = null;
      this.cmd = null;
    }

    EvalPlayer.prototype.start = function() {
      var dfd;
      dfd = $.Deferred();
      dfd.resolve([
        {
          'id': 'code'
        }
      ]);
      return dfd.promise();
    };

    EvalPlayer.prototype.advance = function() {
      var time;
      time = new Date().getTime();
      this.cmd = this.command(history).toLowerCase();
      time = new Date().getTime() - time;
      return $('#debug').append('advance: ' + time + ": " + this.cmd + '<br>');
    };

    return EvalPlayer;

  })();

  Player = (function() {
    function Player(url, pid) {
      this.url = url;
      this.pid = pid;
      this.lags = [];
      this.id = null;
      this.cmd = null;
    }

    Player.prototype.ajax = function(data) {
      console.log('ajax: ' + JSON.stringify(data, null, 2));
      return $.ajax({
        type: 'GET',
        url: this.url,
        data: data,
        dataType: 'jsonp',
        timeout: 10000,
        jsonpCallback: 'jsonpCallback' + this.pid
      });
    };

    Player.prototype.start = function() {
      console.log('start');
      return this.ajax({
        type: 'start'
      });
    };

    Player.prototype.advance = function() {
      this.cmd = null;
      return this.ping();
    };

    Player.prototype.ping = function() {
      var time;
      time = new Date().getTime();
      return this.ajax({
        type: 'ping',
        id: this.id
      }).done((function(_this) {
        return function(json) {
          _this.lags.push(new Date().getTime() - time);
          if (_this.lags.length > 10) {
            _this.lags.shift();
          }
          $('#time').text(JSON.stringify(_this.lags, null, 2));
          return setTimeout(function() {
            return _this.command();
          }, 1000);
        };
      })(this));
    };

    Player.prototype.command = function() {
      var time;
      time = new Date().getTime();
      return this.ajax({
        type: 'advance',
        id: this.id,
        context: {
          history: history
        }
      }).done((function(_this) {
        return function(json) {
          time = new Date().getTime() - time;
          if (_this.lags.length > 0) {
            time = time - _this.lags.reduce(function(a, b) {
              return a + b;
            }) / _this.lags.length;
          }
          _this.cmd = json.cmd.toLowerCase();
          switch (_this.cmd) {
            case 'scissor':
              console.log('Scissor');
              break;
            case 'paper':
              console.log('Paper');
              break;
            case 'stone':
              console.log('Stone');
              break;
            default:
              console.log('Unknown');
          }
          return $('#debug').append('advance: ' + time + ": " + JSON.stringify(json, null, 2) + '<br>');
        };
      })(this));
    };

    return Player;

  })();

  $(function() {
    console.log('ready');
    return $('#start').click(function() {
      var p1, p2;
      console.log('start');
      p1 = createPlayer(1);
      p2 = createPlayer(2);
      return $.when(p1.start(), p2.start()).then(function(json1, json2) {
        console.log('started');
        p1.id = json1[0].id;
        p2.id = json2[0].id;
        p1.advance();
        p2.advance();
        return process(p1, p2);
      });
    });
  });

  createPlayer = function(index) {
    if ($('input[name="ai' + index + '"]:checked').val() === 'url') {
      return new Player($('#url' + index).val(), index);
    } else {
      return new EvalPlayer($('#code' + index).val(), index);
    }
  };

  process = function(p1, p2) {
    console.log('process');
    if (p1.cmd && p2.cmd) {
      history.push([p1.cmd, p2.cmd]);
      if ((p1.cmd === 'scissor' && p2.cmd === 'paper') || (p1.cmd === 'paper' && p2.cmd === 'stone') || (p1.cmd === 'stone' && p2.cmd === 'scissor')) {
        $('#log').append('Player 1 wins !');
      } else if ((p1.cmd === 'scissor' && p2.cmd === 'stone') || (p1.cmd === 'paper' && p2.cmd === 'scissor') || (p1.cmd === 'stone' && p2.cmd === 'paper')) {
        $('#log').append('Player 2 wins !');
      } else {
        $('#log').append('Draw !');
      }
      $('#log').append('<br>');
      p1.advance();
      p2.advance();
    }
    return setTimeout(function() {
      return process(p1, p2);
    }, 1000);
  };

}).call(this);