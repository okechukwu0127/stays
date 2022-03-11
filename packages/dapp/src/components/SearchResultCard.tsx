import { useContext } from 'react';
import { Box, Text, ResponsiveContext, Image, Grid, Button } from 'grommet';
import Logger from '../utils/logger';
import type { LodgingFacility } from 'stays-data-models'
import { useNavigate, useLocation, Navigate } from 'react-router-dom';

//FAKE DATA
import { faker } from 'stays-data-models';
const {
  iterator,
  createFakeSpace,
  createFakeLodgingFacility,
} = faker;

// Initialize logger
const logger = Logger('Account');

export const SearchResultCard: React.FC<{ lodgingFacility?: LodgingFacility }> = ({ }) => {
  const size = useContext(ResponsiveContext);
  const lodgingFacility = createFakeLodgingFacility()
  const space = createFakeSpace()
  const navigate = useNavigate();
  return (
    <Box
      border
      direction='row'
      align='center'
      margin='small'
    >
      <Grid
        responsive
        width='100%'
        rows={['xsmall', 'small', 'xsmall']}
        columns={['medium', 'flex']}
        gap="medium"
        areas={[
          { name: 'img', start: [0, 0], end: [1, 2] },
          { name: 'header', start: [1, 0], end: [1, 1] },
          { name: 'main', start: [1, 1], end: [1, 1] },
          { name: 'action', start: [1, 2], end: [1, 2] },
        ]}
        align='center'
      >
        <Box gridArea="img" height="100%" >
          <Image
            fit="cover"
            src={lodgingFacility.media.logo}
          />
        </Box>
        <Box gridArea="header">
          <Text size='xxlarge'  >
            {lodgingFacility.alternativeName}
          </Text>
          <Text size='large'  >
            {lodgingFacility.locations === undefined ? '' : lodgingFacility.locations[0].address.locality}
          </Text>
        </Box>
        <Box direction='column' justify='start' gridArea="main">
          lordem
        </Box>
        <Box pad={{ right: 'medium' }} direction='row' justify='between' align='center' gridArea="action">
          <Text size='large'>From: {space.pricePerNight}</Text>
          <Button
            size='large'
            label='Check Spaces'
            onClick={() => navigate(`/space/${space.id}`)}
          />
        </Box>
      </Grid>
    </Box>
  );
};
