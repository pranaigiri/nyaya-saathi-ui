# Fix: Web users stare at a blank white screen while Flutter web initializes

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/flutter-web-loading-progress
- **Needs new dependency**: none

## Why

Flutter web takes 3-5 seconds to download CanvasKit, fonts, and assets. Users see a blank white page and assume the web app is frozen. A branded progress bar that tracks real loader milestones provides visual reassurance.

## Where

```html
<!-- web/index.html:35 — current -->
<body>
  <script src="flutter_bootstrap.js" async></script>
</body>
```

## The fix

Add branded loader markup and styles to `web/index.html`:
```html
<!-- target: in web/index.html -->
<head>
  ...
  <style>
    body {
      margin: 0;
      background-color: #0F172A;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      height: 100vh;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    }
    .loader-brand {
      color: #FFFFFF;
      font-size: 20px;
      font-weight: 600;
      margin-bottom: 20px;
      letter-spacing: 0.5px;
    }
    .progress-container {
      width: 180px;
      height: 6px;
      background-color: rgba(255, 255, 255, 0.15);
      border-radius: 8px;
      overflow: hidden;
    }
    .progress-bar {
      height: 100%;
      width: 25%;
      background: linear-gradient(90deg, #1E3A8A, #0D9488);
      border-radius: 8px;
      transition: width 0.4s ease;
    }
  </style>
</head>
<body>
  <div class="loader-brand">Nyaya Saathi</div>
  <div class="progress-container">
    <div class="progress-bar" id="app-progress"></div>
  </div>
  <script src="flutter_bootstrap.js" async></script>
</body>
```

## Steps

1. In `web/index.html`, add the style block and loader HTML.

## Check it

`grep -c "progress-container" web/index.html` -> 1.

## Don't touch

- Do not alter `flutter_bootstrap.js` script tag source.

## STOP if

- `web/index.html` does not exist in project root.

## When you're done

Opening the application in a web browser displays an elegant Nyaya Saathi branded loading bar until the Flutter engine takes over.
