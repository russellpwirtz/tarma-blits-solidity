// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import "./IHappinessModule.sol";
import "./ILockModule.sol";
// import "./ICheckinModule.sol";
import "hardhat/console.sol";

contract Tarma is ERC1155, Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    IERC20 public blit;
    // address happinessModuleAddress;
    address lockModuleAddress;
    // address checkinModuleAddress;

    uint256 constant MILLIS_PER_DAY = 86400000;
    uint256 constant BLIT_BALANCE_INITIAL_CREDIT = 100;

    struct TarmaCollectible {
        string name;
        uint256 id;
        uint256 multiplier;
        Memories memories;
        TarmaStates tarmaState;
        // IHappinessModule happinessModule;
        ILockModule lockModule;
        // ICheckinModule checkinModule;
    }

    struct Memories {
        uint256 bornDate;
        uint256 lastUpdated;
        uint256 disciplined;
        uint256 energy;
    }

    enum TarmaStates {
        egg,
        baby,
        teenager,
        adult,
        senior
    }

    mapping(address => TarmaCollectible[]) public playerTarmas;
    uint256 public tarmasCreated;

    constructor(address _blitAddress, address _lockModuleAddress) ERC1155("") {
        blit = IERC20(_blitAddress);
        // happinessModuleAddress = _happinessModuleAddress;
        lockModuleAddress = _lockModuleAddress;
        // checkinModuleAddress = _checkinModuleAddress;
    }

    /**
     * Public Functions
     */

    function checkin(uint256 tarmId) public nonReentrant {
        address _sender = msg.sender;
        require(playerTarmas[_sender].length > 0, "No Tarmas found");

        // TarmaCollectible storage _tarma = playerTarmas[_sender][tarmId];

        // uint256 _blitEarned = _tarma.checkinModule.checkin(
        //     _sender,
        //     tarmId,
        //     _tarma.multiplier,
        //     // _tarma.happinessModule.getHappinessLevel()
        //     1,
        //     1,
        //     1
        // ); // TODO

        // string memory _blitEarnedString = Strings.toString(_blitEarned);
        // console.log("About to send blit: ", _blitEarnedString);
        // uint256 _amountHeld = blit.balanceOf(_sender);
        // string memory _blitHeldString = Strings.toString(_amountHeld);
        // console.log("Held blit: ", _blitHeldString);

        // if (_blitEarned > 0) {
        //     blit.transfer(_sender, _blitEarned);
        // }
    }

    /**
     * External functions
     */

    function createTarma(
        string memory name,
        uint256 cost,
        uint256 multiplier,
        address recipientAddress
    ) public onlyOwner {
        tarmasCreated = tarmasCreated.add(1);

        TarmaCollectible memory _tarma = TarmaCollectible({
            name: name,
            id: tarmasCreated,
            multiplier: multiplier,
            memories: Memories({
                bornDate: block.timestamp,
                lastUpdated: 0,
                disciplined: 1,
                energy: 1
            }),
            tarmaState: TarmaStates.baby,
            lockModule: ILockModule(lockModuleAddress)
        });

        playerTarmas[recipientAddress].push(_tarma);

        _tarma.lockModule.initialize(
            IERC1155(this),
            (playerTarmas[recipientAddress].length) - 1,
            blit,
            0
        );

        _mint(recipientAddress, tarmasCreated, 1, "");

        emit TarmaCreated(
            recipientAddress,
            name,
            tarmasCreated,
            cost,
            multiplier
        );
    }

    function unlock(uint256 tarmaId) public nonReentrant {
        TarmaCollectible storage _tarma = playerTarmas[msg.sender][tarmaId];

        _tarma.lockModule.unlock(IERC1155(this), tarmaId);

        playerTarmas[msg.sender][tarmaId] = _tarma;

        emit TarmaUnlocked(msg.sender, tarmaId);
    }

    /**
     * Events
     */

    event TarmaCreated(
        address indexed owner,
        string name,
        uint256 nftId,
        uint256 cost,
        uint256 multiplier
    );
    event TarmaUnlocked(address indexed owner, uint256 nftId);
}
