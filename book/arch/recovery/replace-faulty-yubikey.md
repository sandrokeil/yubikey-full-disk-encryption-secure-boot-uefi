# Replace a faulty YubiKey

> You will need the 20 byte length secret key from the initialization.

The secret key in the example here is *7fb21c407f0693ab30259664680a047f8c462ccb*.

```
LOGGING START,3/9/2018 5:00 PM
Challenge-Response: HMAC-SHA1,3/9/2018 5:00 PM,2,,,7fb21c407f0693ab30259664680a047f8c462ccb,,,0,0,0,0,0,0,0,0,0,0
```

Repalce `[Your secret key]` with your secret key from initialization.

```
ykpersonalize -a[your secret key] -v -2 -ochal-resp -ochal-hmac -ohmac-lt64 -ochal-btn-trig -oserial-api-visible
```

That's it, this YubiKey should work like the others.

> If you use YubiKey Login you have to reread chapter *07: Enable YubiKey Login* due initial challenge.