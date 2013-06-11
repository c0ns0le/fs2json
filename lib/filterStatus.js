"use strict";

module.exports = function () {
  var _break = false;
  var _dropNode = false;

  return {
    facade: {
      break: function () {
        _break = true;
      },
      continue: function () {
        _break = _break || false;
      },
      drop: function () {
        _dropNode = true;
      },
      keep: function () {
        _dropNode = _dropNode || false;
      }
    },
    mustBreak: function () {
      return _break;
    },
    isDroppedNode: function () {
      return _dropNode;
    }
  };
};
