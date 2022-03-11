import type { Space as SpaceType } from 'stays-data-models';
import { PageWrapper } from './PageWrapper';
import { Box, Text, Button, ResponsiveContext, Image, Card, Grid, InfiniteScroll, Carousel, Tabs, Tab } from 'grommet';

//FAKE DATA
import { faker } from 'stays-data-models';
const {
  iterator,
  createFakeSpace,
  createFakeLodgingFacility,
} = faker;

export const Space = () => {
  const searchParams = new URLSearchParams(window.location.search)
  const lodgingFacility = createFakeLodgingFacility()
  const space = createFakeSpace()
  return (
    <PageWrapper
      breadcrumbs={[
        {
          path: '/search',
          label: 'Search'
        }
      ]}
    >
      <Box
        border
        flex={true}
        align='center'
        overflow='auto'
        pad='small'
      >
        <Box flex={false} width='xxlarge' >
          <Box pad={{ bottom: 'small' }}>
            <Text size='xxlarge'>
              {lodgingFacility.alternativeName}
            </Text>
            <Text size='large'>
              {lodgingFacility.locations === undefined ? '' : lodgingFacility.locations[0].address.locality}
            </Text>
          </Box>
          <Box gridArea="img" height="large" pad={{ bottom: 'medium' }}>
            <Carousel>
              { }
              {space.media.images?.map((space) =>
                <Image
                  fit="cover"
                  src={space.uri}
                />
              )}
            </Carousel>
          </Box>
          <Box pad={{ bottom: 'small' }}>
            <Text size='xxlarge'>
              Info
            </Text>
          </Box>
          <Box pad={{ bottom: 'medium', left: 'small' }}>
            <Text>lasd asda as dsa dads  sad asdasd sadas dsadasd asd as d asd asd asdasd asd asd asd asd asd as dasd </Text>
          </Box>
          <Box>
            <Box pad={{ bottom: 'small' }}>
              <Text size='xxlarge'>Room type</Text>
            </Box>
            <Tabs alignControls='start'>
              {/* {(lodgingFacility.spaces as SpaceType[]).map((space) => )} */}
              <Tab title={space.type}>
                <Box width='100%' pad="medium">
                  <Text>{space.description}</Text>
                  <Text size='large'>From: {space.pricePerNight ?? '$$$'} DAI</Text>
                  <Button
                    size='large'
                    label='Book with DAI'
                    onClick={() => console.log(`/space/${space.id}`)}
                  />
                </Box>
              </Tab>
            </Tabs>
          </Box>
          <Box pad={{ right: 'medium' }} direction='row' justify='between' align='center' gridArea="action">

          </Box>
        </Box>
      </Box>
    </PageWrapper>
  );
};
