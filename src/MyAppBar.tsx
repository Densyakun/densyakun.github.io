import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import { Button, IconButton } from '@mui/material';
import { GitHub } from '@mui/icons-material';

export default function MyAppBar() {
  return <Box sx={{ flexGrow: 1 }}>
    <AppBar position="static" sx={{ backgroundColor: '#0088BB' }}>
      <Toolbar>
        <Typography
          fontFamily='"Noto Sans JP","Roboto","Helvetica","Arial",sans-serif'
          fontWeight={700}
          variant="h5"
          component="div"
          sx={{ flexGrow: 1 }}
        >
          電車君のホームページ
        </Typography>
        <IconButton color="inherit" href="https://github.com/Densyakun" target="_blank">
          <GitHub />
        </IconButton>
        <Button color="inherit" href="http://densyakun.hateblo.jp/" target="_blank">
          ブログ
        </Button>
        <Button color="inherit" href="http://profile.hatena.ne.jp/Densyakun/" target="_blank">
          プロフィール
        </Button>
      </Toolbar>
    </AppBar>
  </Box>;
}