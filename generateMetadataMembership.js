const fs = require('fs')

const artistNames = [
  'Calicho Arevalo',
  'Alana McCarthy',
  'Samantha Pordes',
  'Martin Aveling',
  'Nahuel Bardi',
  'Callum Pickard',
  'Joel Ntm',
  'Carlos Nieto',
  'Neda Mamo',
  'Angga Tantama',
  'Jaye Kang',
  'Iqbal Hakim Boo',
]

const BASE_URI = ''

const outputDir = `membership_nft_metadata/`
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true })
} else {
  fs.rmdir(`membership_nft_metadata/`, () => {})
}
for (let i = 1; i <= 2232; i++) {
  let rarity
  let artist
  if (i<= 12) {
    rarity = {
      type: 'string',
      value: 'Mycelia',
      description:
        'Valorize Mycelia NFTs are a collection of 12 1 of 1 NFTs by a group of artists. They grant you the benefits described in the benefits property',
      benefits: [
        'An NFT that is part of the most unique collection of art in NFT history',
        'The highest amount of quarterly $VALOR token airdrops',
        'Premium Customer Support for the first 3 months guaranteed',
        'Access to the exclusive membership section of the ValorizeDAO discord',
        'Free access to our upcoming Tokenomics Academy Course',
      ],
    }
    artist = artistNames[i % 12]
  } else if (i>12 && i<=72) {
    rarity = {
      type: 'string',
      value: 'Obsidian',
      description:
      'Valorize Obsidian NFTs are a collection of 12 1 of 1 NFTs by a group of artists. They grant you the benefits described in the benefits property',
      benefits: [
        'An NFT that is part of the most unique collection of art in NFT history',
        'The highest amount of quarterly $VALOR token airdrops',
        'Premium Customer Support for the first 3 months guaranteed',
        'Access to the exclusive membership section of the ValorizeDAO discord',
        'Free access to our upcoming Tokenomics Academy Course',
      ],
    }
    artist = artistNames[i % 12]
  } else if (i > 72 && i <=  312) {
    rarity = {
      type: 'string',
      value: 'Diamond',
      description:
      'Valorize Diamond NFTs are a collection of 12 1 of 1 NFTs by a group of artists. They grant you the benefits described in the benefits property',
      benefits: [
        'An NFT that is part of the most unique collection of art in NFT history',
        'The highest amount of quarterly $VALOR token airdrops',
        'Premium Customer Support for the first 3 months guaranteed',
        'Access to the exclusive membership section of the ValorizeDAO discord',
        'Free access to our upcoming Tokenomics Academy Course',
      ],
    }
    artist = artistNames[i % 12]
  } else if (i > 312 && i<=1032) {
    rarity = {
      type: 'string',
      value: 'Gold',
      description:
        'Valorize Silver NFTs are a collection of 1000 NFTs by artist Valerii Spornikov which grant you the benefits described in the benefits property',
      benefits: [
        'An NFT that is part of the most unique collection of art in NFT history',
        'A moderate amount of quarterly $VALOR token airdrops',
        'Premium Customer Support for the first 3 months guaranteed',
        'Access to the exclusive membership section of the ValorizeDAO discord',
        'Free access to our upcoming Tokenomics Academy Course',
      ],
    }
    artist = artistNames[i % 12]
  } else if (i > 1032 && i <= 2232) {
    rarity = {
      type: 'string',
      value: 'Silver',
      description:
        'Valorize Silver NFTs are a collection of 1000 NFTs by artist Valerii Spornikov which grant you the benefits described in the benefits property',
      benefits: [
        'An NFT that is part of the most unique collection of art in NFT history',
        'The lowest amount of quarterly $VALOR token airdrops',
        'Premium Customer Support for the first 3 months guaranteed',
        'Access to the exclusive membership section of the ValorizeDAO discord',
        'Free access to our upcoming Tokenomics Academy Course',
      ],
    }
    artist = artistNames[i % 12]
  }

  let data = {
    title: 'ValorizeDAO Membership NFT',
    image_url: `${BASE_URI}/${i}.png`,
    properties: {
      token_id: i,
      rarity,
      artist
    },
  }
  const output = JSON.stringify(data)

  fs.writeFile(outputDir + i + '.json', output, (err) => {
    if (err) throw err
    console.log(`File ${i} has been saved!`)
  })
}
