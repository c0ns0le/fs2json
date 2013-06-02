"use strict";

//KEEP/DROP : send 'path' or not
//CONTINUE/BREAK: continue if dir or not
module.exports = function () {
  var broken = false;
  var dropped = false;

  return {
    facade: {
      break: function () {
        broken = true;
      },
      continue: function () {
        broken = broken || false;
      },
      drop: function () {
        dropped = true;
      },
      keep: function () {
        dropped = dropped || false;
      }
    },
    brokenNode: function () {
      return broken;
    },
    droppedNode: function () {
      return dropped;
    }
  };
};
