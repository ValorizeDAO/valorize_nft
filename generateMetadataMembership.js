const fs = require('fs')

const artistNames = [//royalty distributor addresses
  'Calicho Arevalo', //0x0D9666506da4ace5ef4aa10863992853158BB6e2
  'Alana McCarthy',  //0xC0B58E3212C0526170589f0B28Ec2A5008f70105
  'Samantha Pordes', //0xe5cc88F15029b825565B5d7Fc88742F156C47e04
  'Martin Aveling',  //0x01Ed59b19E9e837B58a8cDD217F8aCD7E7905F13
  'Nahuel Bardi',    //0x542377824BEFE28121C2D807F6aBde8791cbD81e
  'Callum Pickard',  //0x52d83bA8E826A9cC1393355De61653274482DD80
  'Joel Ntm',        //0xb40FDd5d3fEdB5c2946879D6Bd27D7D359076B13
  'Carlos Nieto',    //0x7E73FF88483C51E12237A2e0F5375232167dDa46
  'Neda Mamo',       //0x8d834c8641FbdBB0DFf24a5c343F2e459ea96923
  'Angga Tantama',   //0xFF6be29Bc09988E528CD22BB9D3a457D1726343B
  'Jaye Kang',       //0xe7cbA56940aC750429139Ca6a31AE6e819C009bF
  'Iqbal Hakim Boo', //0xD2c280935c9B7A3Bf07bde3FB3e10b1E58206873
]

const animals = [
  'Bee',
  'Bee',
  'Ant',
  'Octopus',
  'Octopus',
  'Ant',
  'Octopus',
  'Bee',
  'Bee',
  'Ant',
  'Ant',
  'Octopus'
]

const BASE_URI = 'https://example.com'

const outputDir = `membership_nft_metadata/`
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true })
} else {
  fs.rmdir(`membership_nft_metadata/`, () => {})
}
for (let i = 1; i <= 2232; i++) {
  let rarity
  let artist
  let animal
  if (i <= 12) {
    animal = animals[i % 12]
    artist = artistNames[i % 12]
    rarity = {
      type: 'string',
      value: 'Mycelia',
      description:
        'Valorize Mycelia NFTs are a collection of 12 1 of 1 NFTs each made by a different gifted artist. Holding a Mycelia NFT will grant you the benefits described in the benefits property',
      benefits: [
        'An NFT that is part of the most unique collection of art in NFT history',
        'The highest amount of quarterly $VALOR token airdrops',
        'Access to the exclusive membership section of the ValorizeDAO discord',
        'Free access to our upcoming Tokenomics Academy Course',
      ],
    }
  } else if (i > 12 && i <= 72) {
    animal = animals[i % 12]
    artist = artistNames[i % 12]
    rarity = {
      type: 'string',
      value: 'Obsidian',
      description:
      'Valorize Obsidian NFTs are a collection of 60 NFTs as each Obsidian Art has 5 copies per artist. Holding an Obsidian NFT will you the benefits described in the benefits property',
      benefits: [
        'An NFT that is part of the most unique collection of art in NFT history',
        'A large amount of quarterly $VALOR token airdrops',
        'Access to the exclusive membership section of the ValorizeDAO discord',
        'Free access to our upcoming Tokenomics Academy Course',
      ],
    }
  } else if (i > 72 && i <=  312) {
    animal = animals[i % 12]
    artist = artistNames[i % 12]
    rarity = {
      type: 'string',
      value: 'Diamond',
      description:
      'Valorize Diamond NFTs are a collection of 240 NFTs as each Diamond Art has 20 copies per artist. Holding a Diamond NFT will grant you the benefits described in the benefits property',
      benefits: [
        'An NFT that is part of the most unique collection of art in NFT history',
        'An decent amount of quarterly $VALOR token airdrops',
        'Access to the exclusive membership section of the ValorizeDAO discord',
        'Free access to our upcoming Tokenomics Academy Course',
      ],
    }
  } else if (i > 312 && i <= 1032) {
    animal = animals[i % 12]
    artist = artistNames[i % 12]
    rarity = {
      type: 'string',
      value: 'Gold',
      description:
        'Valorize Gold NFTs are a collection of 720 NFTs as each Gold Art has 60 copies per artist. Holding a Gold NFT will grant you the benefits described in the benefits property',
      benefits: [
        'An NFT that is part of the most unique collection of art in NFT history',
        'A moderate amount of quarterly $VALOR token airdrops',
        'Access to the exclusive membership section of the ValorizeDAO discord',
        'Free access to our upcoming Tokenomics Academy Course',
      ],
    }
  } else if (i > 1032 && i <= 2232) {
    animal = animals[i % 12]
    artist = artistNames[i % 12]
    rarity = {
      type: 'string',
      value: 'Silver',
      description:
        'Valorize Silver NFTs are a collection of 1200 NFTs as each Silver Art has 100 copies. Holding a Silver NFT will grant you the benefits described in the benefits property',
      benefits: [
        'An NFT that is part of the most unique collection of art in NFT history',
        'The lowest amount of quarterly $VALOR token airdrops',
        'Access to the exclusive membership section of the ValorizeDAO discord',
        'Free access to our upcoming Tokenomics Academy Course',
      ],
    }
  }

  let data = {
    title: 'ValorizeDAO Membership NFT',
    image_url: `${BASE_URI}/${i}.png`,
    properties: {
      token_id: i,
      animal,
      artist,
      rarity
    },
  }
  const output = JSON.stringify(data)

  fs.writeFile(outputDir + i + '.json', output, (err) => {
    if (err) throw err
    console.log(`File ${i} has been saved!`)
  })
}
