const { Client } = require('pg');
const connectionString = 'postgresql://postgres:pzuSFBaKrkBqXWUCpNcGkgmblyNdLiXw@interchange.proxy.rlwy.net:49912/railway';

const client = new Client({
  connectionString: connectionString,
});

async function run() {
  try {
    await client.connect();
    console.log('Connected');
    const res = await client.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public'
    `);
    console.log('Tables:');
    res.rows.forEach(row => console.log('- ' + row.table_name));
    await client.end();
  } catch (err) {
    console.error('Error:', err.message);
    process.exit(1);
  }
}

run();
