import { Card, CardActionArea, CardActions, CardContent, CardMedia, Chip, Collapse, Container, Grid, IconButton, Link, List, ListItemButton, ListItemText, ListSubheader, Paper, Stack, Typography } from '@mui/material';
import Box from '@mui/material/Box';
import MyAppBar from './MyAppBar';
import { useState } from 'react';
import { Apps, ExpandLess, ExpandMore, Link as LinkIcon, Newspaper, SportsEsports, Train } from '@mui/icons-material';
import GitHubIcon from '@mui/icons-material/GitHub';

function NewChip() {
  return <Chip label="New" size="small" sx={{
    marginLeft: 1,
    backgroundColor: '#f80',
    color: '#fff',
  }} />;
}

function App() {
  return <>
    <MyAppBar />
    <Container fixed sx={{ paddingTop: 2 }}>
      <Grid container spacing={2}>
        <Grid>
          <LatestNews />
        </Grid>
        <Grid>
          <WebApps />
        </Grid>
        <Grid>
          <Links />
        </Grid>
        <Grid>
          <Games />
        </Grid>
        <Grid>
          <RailwayMaps />
        </Grid>
        <Grid>
          <Bvets />
        </Grid>
      </Grid>

      <Typography variant="caption">
        Copyright &copy; 2016 Densyakun All Rights Reserved.
      </Typography>
    </Container>
  </>;
}

function LatestNews() {
  const news = [
    ['2025/05/21', 'HPのデザイン変更、自作のWebアプリを追加'],
    ['2021/09/16', '鉄道整備計画を追加'],
    ['2020/05/25', 'Bve5路線データを2つ公開'],
    ['2019/07/27', 'Twitterアカウント再開について更新'],
    ['2019/03/23', 'Twitterについて更新'],
    ['2018/09/20', 'デザインなどを一部更新'],
    ['2018/09/11', 'トップにTwitterアカウントのロックについて記載'],
    ['2018/09/03', 'ゲームページにBukkitプラグインを「PvP1vs1」、「PvPFFA」、「ArcadeTosochu」を追加'],
    ['2018/02/12', 'ゲームページにBukkitプラグインを「MiniGameManager」と「ChatTempMute」を追加、ヘッダー背景追加'],
    ['2018/02/11', 'ゲームページに4つBukkitプラグインを追加'],
    ['2017/10/01', 'ゲームページにBukkitプラグイン「AnimalRide」を追加'],
    ['2017/09/12', 'ゲームページにBukkitプラグイン「ChatSound」を追加'],
    ['2017/09/11', 'DensyakunCreative廃止に合わせ更新'],
    ['2016/06/21', 'ブログ開設に伴う更新'],
    ['2016/02/27', 'ホームページ開設'],
  ];

  const [open, setOpen] = useState(false);

  const handleClick = () => {
    setOpen(!open);
  };

  if (news.length === 0) return null;

  return <Box>
    <List
      dense
      sx={{ width: '100%', maxWidth: 360, bgcolor: 'background.paper' }}
      component="nav"
      aria-labelledby="nested-list-subheader"
      subheader={
        <Stack direction="row" alignItems="center">
          <Newspaper />
          <ListSubheader component="div" id="nested-list-subheader">
            最新情報
          </ListSubheader>
        </Stack>
      }
    >
      <ListItemButton onClick={handleClick}>
        <ListItemText primary={news[0][1]} secondary={news[0][0]} />
        <NewChip />
        {open ? <ExpandLess /> : <ExpandMore />}
      </ListItemButton>
      <Collapse in={open} timeout="auto" unmountOnExit sx={{ float: 'left' }}>
        <List component="div" disablePadding>
          {news.map((item, index) => index === 0 ? null : (
            <ListItemButton key={index}>
              <ListItemText primary={item[1]} secondary={item[0]} />
            </ListItemButton>
          ))}
        </List>
      </Collapse>
    </List>
  </Box>;
}

function WebApps() {
  return <Box>
    <Stack direction="row" alignItems="center">
      <Apps />
      <h2>Webアプリ</h2>
    </Stack>

    <Grid container spacing={2}>
      <Grid>
        <Card sx={{ maxWidth: 345 }}>
          <CardActionArea href="https://memo-relation.vercel.app/" target="_blank">
            <CardContent>
              <Typography gutterBottom variant="h5" component="div">
                memo-relation
                <NewChip />
              </Typography>
              <Typography variant="body2" sx={{ color: 'text.secondary' }}>
                閲覧可能なアカウントを限定できるプライベートメモに、別のメモをタグ付けしたり、タグにもタグ付けできる、メモを管理するWebアプリ
              </Typography>
            </CardContent>
          </CardActionArea>
          <CardActions>
            <IconButton href="https://github.com/Densyakun/memo-relation" target="_blank">
              <GitHubIcon />
            </IconButton>
          </CardActions>
        </Card>
      </Grid>
      <Grid>
        <Card sx={{ maxWidth: 345 }}>
          <CardActionArea href="https://degree-name-and-lyrics.vercel.app/" target="_blank">
            <CardContent>
              <Typography gutterBottom variant="h5" component="div">
                Transposed chords
                <NewChip />
              </Typography>
              <Typography variant="body2" sx={{ color: 'text.secondary' }}>
                楽曲の移調されたコードの度数名（ディグリーネーム）を表示するWebアプリ
              </Typography>
            </CardContent>
          </CardActionArea>
        </Card>
      </Grid>
    </Grid>
  </Box>;
}

function Links() {
  return <Box>
    <Stack direction="row" alignItems="center">
      <LinkIcon />
      <h2>リンク</h2>
    </Stack>

    <ul>
      <li>
        <Link href="https://github.com/Densyakun/Densyakun/blob/main/Repositories.md#bukkit-spigot-plugins" display="flex" alignItems="center">
          <Stack sx={{ width: "24px", height: "24px" }} alignItems="center" justifyContent="center">
            <img src="282774.webp" width="19px" height="19px" />
          </Stack>
          Minecraft Bukkit (Spigot) プラグイン
        </Link>
      </li>
      <li>
        <a href="http://densyakuncreate.wiki.fc2.com/">電車君制作所</a>
      </li>
    </ul>
  </Box>
}

function Games() {
  return <Box>
    <Stack direction="row" alignItems="center">
      <SportsEsports />
      <h2>自作ゲーム</h2>
    </Stack>

    <Card sx={{ maxWidth: 345 }}>
      <CardActionArea href="http://blueprint.wiki.fc2.com/">
        <CardMedia
          component="img"
          height="140"
          image="688a20e758611a768f123c2cb8413338.png"
        />
        <CardContent>
          <Typography gutterBottom variant="h5" component="div">
            BluePrint
          </Typography>
          <Typography variant="body2" sx={{ color: 'text.secondary' }}>
            2015年公開。唯一完成したゲーム作品。木を切って道具を作り、家をたてるサンドボックスゲーム。バグあり
          </Typography>
        </CardContent>
      </CardActionArea>
    </Card>
  </Box>;
}

function RailwayMaps() {
  return <Box>
    <Stack direction="row" alignItems="center">
      <Train />
      <h2>鉄道マップ</h2>
    </Stack>

    <ul>
      <li><a href="https://www.google.com/maps/d/edit?mid=1R6afAaHffBeTtB_Xz9MpJ5GuY_RjtjZr&usp=sharing">鉄道整備計画</a></li>
      <li><a href="https://www.google.com/maps/d/edit?mid=z4ftE0ZIEcl0.kEf3qVZWoqXA&usp=sharing">電車君の架空鉄道網</a></li>
    </ul>
  </Box>;
}

function Bvets() {
  return <Box>
    <Stack direction="row" alignItems="center">
      <Stack sx={{ width: "24px", height: "24px" }} alignItems="center" justifyContent="center">
        <img src="n1207192icon_b.gif" width="19px" height="19px" />
      </Stack>
      <h2>BVE Trainsim</h2>
    </Stack>

    <ul>
      <li><a href="https://www.google.com/maps/d/u/0/edit?mid=1hZ5QCixo0WHI2iBgW-V3CkDe3bj5pHU&usp=sharing">BVE5対応路線データ（マイマップ）</a></li>
    </ul>

    <Paper elevation={3} sx={{ padding: 2 }}>
      <h3>BVE5 自作 路線データ</h3>
      <Grid container spacing={2}>
        <Grid>
          <Card sx={{
            maxWidth: 345,
            border: "5px solid",
            borderImage: "linear-gradient(#C8006B 50%, #00377E 50%) 1",
          }}>
            <CardActionArea href="https://drive.google.com/open?id=1M6zdSz5kKkuAdNgGVcjtVBfD2P_i-zYe" target="_blank">
              <CardContent>
                <Typography gutterBottom variant="h5" component="div">
                  京王相模原線 準特急 新宿→橋本
                </Typography>
                <Typography variant="body2" sx={{ color: 'text.secondary' }}>
                  2020/05/25公開。グリーンマットで景観はありません
                </Typography>
              </CardContent>
            </CardActionArea>
          </Card>
        </Grid>
        <Grid>
          <Card sx={{
            maxWidth: 345,
            border: "5px solid",
            borderImage: "linear-gradient(0.375turn, #f20b49 25%, #0f51af 25%, #0f51af 50%, #f20b49 50%, #f20b49 75%, #0f51af 75%) 1",
          }}>
            <CardActionArea href="https://drive.google.com/open?id=1L4HCMTcXFHWpANtyg1sieLAb98I9AJlE" target="_blank">
              <CardContent>
                <Typography gutterBottom variant="h5" component="div">
                  つくばエクスプレス 通快 つくば→秋葉原
                </Typography>
                <Typography variant="body2" sx={{ color: 'text.secondary' }}>
                  2020/05/25公開。途中までしか開発できてません
                </Typography>
              </CardContent>
            </CardActionArea>
          </Card>
        </Grid>
      </Grid>
    </Paper>
  </Box>;
}

export default App;
