describe("rocketmind.Restaurantery", function() {
  var restauranteryParams;
  var restaurantery;
  var restauranteryStylesheetId = "#rm-restaurantery-stylesheet";
  var host = "localhost:3000";
  var restaurant_id = "denis";

  function restauranteryParams() {
    return;
  }

  beforeEach(function() {
    loadFixtures("rocketmind_$.html");
    jQuery(restauranteryStylesheetId).remove();
    jQuery("embed").each(function() {
      this.rerender = jQuery(this).attr("wmode") !== "opaque";
    });
    restauranteryParams = {
      restaurant_id: restaurant_id,
      parent: FIXTURES_CONTAINER_ID,
      host: host
    };
    restaurantery = rocketmind.Restaurantery(restauranteryParams);
  });

  describe("#Restaurantery", function() {
    it("returns restaurantery instance", function() {
      expect(restaurantery).toBeObject();
    });

    it("loads restaurantery stylesheet into html head", function() {
      expect(jQuery("head " + restauranteryStylesheetId)).toExist();
    });

    describe("exists flash objects with window mode other than opaque", function() {
      it("sets all 'embed' elements wmode attribute to opaque", function() {
        expect(jQuery("embed")).toHaveAttr("wmode", "opaque");
      });

      it("re-renders all modified embed elements", function() {
        jQuery("embed").each(function() {
          if (jQuery(this).attr("original-wmode") === "opaque")
            expect(this.rerender).toBeFalse();
          else
            expect(this.rerender).toBeUndefined();
        });
      });
    });

    describe("exists button container", function() {
      var id = "#button-test";

      beforeEach(function() {
        removeWidget();
        jQuery(id).append("<div id='restaurantery-buttonCont'></div>");
        restaurantery = rocketmind.Restaurantery(restauranteryParams);
      });

      it("initiates reservations button in restaurantery button container", function() {
        expect(jQuery(id)).toContain("#rm-restaurantery-button");
      });

      it("animates shine effect on reservations button", function() {
        //TODO
      });
    });

    it("does not initiate reservations button unless button container does not exist", function() {
      expect(jQuery("body")).not.toContain("#rm-restaurantery-button");
    });

    it("animates: spring & shine effects on reservations tab", function() {
      //TODO
    });

    describe("hash parameter 'withoutTab' is true", function() {
      beforeEach(function() {
        removeWidget();
        restauranteryParams.withoutTab = true;
        restaurantery = rocketmind.Restaurantery(restauranteryParams);
      });

      it("does not create tab", function() {
        expect(jQuery(restauranteryId("tab"))).not.toExist();
      });
    });

    it("creates tab with clickable link", function() {
      var cont = jQuery("#rm-restaurantery");
      expect(cont).toExist();
      expect(cont).toContain("#rm-restaurantery-tab #rm-restaurantery-link");
    });

    it("creates hidden widget dialog", function() {
      var dialogId = "#rm-restaurantery-dialog";
      expect(jQuery("#rm-restaurantery")).toContain(dialogId);
      waitsUntilRestauranteryStylesheetLoaded();
      runs(function() {
        expect(jQuery(dialogId)).toHaveCss("visibility", "hidden");
      });
    });
  });

  describe("on link click event", function() {
    afterEach(function() {
      browserWindow().fullScreen();
    });

    describe("normal size device(window height greater than 680px)", function() {
      beforeEach(function() {
        browserWindow().resizeTo(1600, 1200, clickRestauranteryLink);
      });

      it("opens widget dialog", function() {
        expect(jQuery("#rm-restaurantery-dialog")).toHaveCss("visibility", "visible");
      });

      it("horizontaly centers dialog", function() {
        var dialog = jQuery("#rm-restaurantery-dialog");
        var offsetLeft = dialog.offset().left;
        var offsetRight = $(FIXTURES_CONTAINER_ID).width() - (offsetLeft + dialog.outerWidth());
        var horizontalOffsetsDifference = Math.abs(offsetLeft - offsetRight);
        expect(horizontalOffsetsDifference).toBeLessOrEqual(1);
      });

      it("displays overlay", function() {
        expect(jQuery("#rm-restaurantery-overlay")).toBeVisible();
      });

      it("displays loading animation", function() {
        expect(jQuery("#rm-restaurantery-loading")).toBeVisible();
      });

      it("vertically positions dialog near window center", function() {
        expect(viewPortOffsetTop("#rm-restaurantery-dialog")).toEqual(80);
      });

      it("loads reservation first step", function() {
        expect(jQuery("#rm-restaurantery-iframe")).toHaveAttr("src", "http://" + host + "/make_reservation/" + restaurant_id + "/first_step");
      });
    });

    describe("small size device(window height less or equal 680px)", function() {
      beforeEach(function() {
        browserWindow().resizeTo(320, 480, clickRestauranteryLink);
      });

      it("vertically positions dialog near window top", function() {
        expect(viewPortOffsetTop("#rm-restaurantery-dialog")).toEqual(36);
      });
    });
  });

  describe("on iframe loaded event", function() {
    beforeEach(function() {
      openWidgetAndWaitUntilLoaded();
    });

    it("hides loading animation", function() {
      expect(jQuery("#rm-restaurantery-loading")).toBeHidden();
    });

    it("shows iframe", function() {
      expect(jQuery("#rm-restaurantery-iframe")).toHaveCss("visibility", "visible");
    });

    it("shows close button", function() {
      expect(jQuery("#rm-restaurantery-closeButton")).toBeVisible();
    });

    describe("widget close button onclick event", function() {
      beforeEach(function() {
        closeWidgetAndWaitUntilClosed();
      });

      it("shows loading animation", function() {
        expect(jQuery("#rm-restaurantery-loading")).toBeVisible();
      });

      it("hides iframe", function() {
        expect(jQuery("#rm-restaurantery-iframe")).toHaveCss("visibility", "hidden");
      });

      it("hides close button", function() {
        expect(jQuery("#rm-restaurantery-closeButton")).toBeHidden();
      });
    });
  });
});
