(async () => {
  while (!Spicetify?.React || !Spicetify?.ReactDOM || !Spicetify?.Platform) {
    await new Promise((resolve) => setTimeout(resolve, 100));
  }

  const isGlobalNav = !!(
    Spicetify.Platform.version >= "1.2.46" ||
    document.querySelector(".globalNav") ||
    document.querySelector(".Root__globalNav") ||
    document.getElementById("global-nav-bar") ||
    document.querySelector(".main-globalNav-searchSection")
  );

  if (isGlobalNav) {
    document.body.classList.add("global-nav");
  } else {
    document.body.classList.add("control-nav");
  }
})();
