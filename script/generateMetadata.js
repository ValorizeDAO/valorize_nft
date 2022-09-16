var fs = require('fs');

const BASE_URI = "ipfs://QmZvUgS3UfT6Zu3zBjuyvNCWLbCWKuZZ5BD3D4HSnJycn4/";

    for (let i = 1; i < 13; i++) {
        let data = { 
            title: "ValorizeDAO Mycelia Product NFT",
            animation_url: BASE_URI + JSON.stringify(i) + "/not_ready.mp4",
            properties: {
                token_id: i,
                rarity: {
                    type: "string",
                    value: "Mycelia",
                    description: "Token launch through valorize.app including premium rewards & tokenomics consultancy"
                }, 
                product_status: {
                    value: "not ready",
                    description: "Cannot launch product until status is ready."
                }
            }
        }
        const output = JSON.stringify(data);
        fs.writeFile("product_nft_metadata/" + data.properties.rarity.value + "_tokenId_" + JSON.stringify(i) + "_" + data.properties.product_status.value + ".json", output, (err) => { 
            if (err) throw err;
            console.log('The file has been saved!');
            });
    }

