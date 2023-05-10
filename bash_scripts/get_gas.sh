curl --location --request POST 'http://127.0.0.1:9123/gas' \
--header 'Content-Type: application/json' \
--data-raw '{
    "FixedAmountRequest": {
        "recipient": "0xbb07e1c9abf4df545c7dd970a49934bd399f7f63324683f6b232656045dbe969"
    }
}'