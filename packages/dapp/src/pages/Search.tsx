import { PageWrapper } from './PageWrapper';
import { SearchForm } from '../components/search/SearchForm';
import { Box } from 'grommet';
import { SearchResultCard } from '../components/SearchResultCard';
import { useAppState } from '../store';

export const Search = () => {
  const { lodgingFacilities } = useAppState();

  const searchParams = new URLSearchParams(window.location.search)
  const departureDate = searchParams.get('departureDate')
  const returnDate = searchParams.get('returnDate')
  const guestsAmount = searchParams.get('guestsAmount')

  return (
    <PageWrapper
      breadcrumbs={[
        {
          path: '/',
          label: 'Home'
        }
      ]}
    >
      {/* <Box flex={true} align='center' overflow='auto'>
        <Box flex={false} width='xxlarge'> */}
          <SearchForm
            initReturnDate={returnDate}
            initDepartureDate={departureDate}
            initGuestsAmount={guestsAmount}
          />
          {lodgingFacilities.map((facility) => <SearchResultCard lodgingFacility={facility} />)}
        {/* </Box>
      </Box> */}
    </PageWrapper>
  );
};
