
const fs = require('fs');

const BASE_URI = "ipfs://QmZvUgS3UfT6Zu3zBjuyvNCWLbCWKuZZ5BD3D4HSnJycn4";
for (let i = 1; i <= 3000; i++) {
    let rarity;
    if (i <= 12) {
        rarity = {
            type: "string",
            value: "Mycelia",
            description: "Valorize Mycelia NFTs are a collection of 12 1 of 1 NFTs by artist Valerii Spornikov which grant you the benefits described in the benefits property",
            benefits: [
                "5 Hours of consultation time with one of our tokenomics experts where we define project parameters, deliverables, KPIs and next steps",
                "Access to Valorize Admin Dashboard for a 3 year minimum",
                "Premium Customer Support for the first 3 months guaranteed",
                "Draft of tokenomic distribution portion of technical communication (whitepaper, blog post, etc...)",
                "Token launch within the Valorize platform if applicable"
            ]
        }
    } else if (i <= 1012) {
        rarity = {
            type: "string",
            value: "Diamond",
            description: "Valorize Diamond NFTs are a collection of 1000 NFTs by artist Valerii Spornikov which grant you the benefits described in the benefits property",
            benefits: [
                "Token launch in the Valorize platform",
                "Access to Valorize Admin Dashboard for a 2 year minimum",
                "Conversation with tokenomics expert to define token within the parameters of the Valorize platform",
                "Priority Customer Support",
            ]
        }
    } else {
        rarity = {
            type: "string",
            value: "Silver",
            description: "Valorize Silver NFTs are a collection of 1000 NFTs by artist Valerii Spornikov which grant you the benefits described in the benefits property",
            benefits: [
                "Token launch in the Valorize platform",
                "Access to Valorize Admin Dashboard for a 1 year minimum",
            ]
        }
    }
    for (let k = 0; k < 3; k++) {
        const product_status = {
            value: ["Not Ready", "Ready", "Redeemed"][k],
            description: [
                "The token cannot be redeemed until the product status is ready",
                "Token is ready, proceed to Valorize to redeem it for its benefits",
                "Token is now redeemed, welcome to the future"
            ][k]
        }
        const url = ["not-ready", "ready", "redeemed"][k]
        let data = {
            title: "ValorizeDAO Product NFT",
            animation_url: `${BASE_URI}/${i}/${url}.mp4`,
            properties: {
                token_id: i,
                rarity,
                product_status,
            }
        }
        const output = JSON.stringify(data);

        const outputDir = "product_nft_metadata/" + JSON.stringify(i)
        if (!fs.existsSync(outputDir)){
            fs.mkdirSync(outputDir, { recursive: true });
        }
        fs.writeFile(outputDir + "/" + url + ".json", output, (err) => {
            if (err) throw err;
            console.log('The file has been saved!');
        });
    }
}
